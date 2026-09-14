-- Kitchen Recipes Schema
-- Run this in your Supabase SQL editor: https://supabase.com/dashboard/project/YOUR_PROJECT/sql

-- Enable UUID extension if not already enabled
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Recipes table
CREATE TABLE IF NOT EXISTS public.recipes (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  
  -- Human-readable slug for URLs (must be unique)
  slug TEXT UNIQUE NOT NULL,
  
  -- Core fields
  title TEXT NOT NULL,
  cuisine TEXT DEFAULT 'Other',
  category TEXT DEFAULT '',
  description TEXT DEFAULT '',
  
  -- Timing
  prep_time INTEGER DEFAULT 0 CHECK (prep_time >= 0),
  cook_time INTEGER DEFAULT 0 CHECK (cook_time >= 0),
  servings TEXT DEFAULT '',
  difficulty TEXT DEFAULT '',
  
  -- Content (JSON arrays)
  tags TEXT[] DEFAULT '{}',
  columns JSONB DEFAULT '[]'::jsonb,  -- Ingredient groups: [{title, items: [{qty, name}]}]
  steps TEXT[] DEFAULT '{}',
  
  -- Optional
  notes TEXT DEFAULT '',
  video_link TEXT DEFAULT '',
  
  -- Ownership & timestamps
  created_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Index for common queries
CREATE INDEX IF NOT EXISTS idx_recipes_cuisine ON public.recipes(cuisine);
CREATE INDEX IF NOT EXISTS idx_recipes_created_by ON public.recipes(created_by);
CREATE INDEX IF NOT EXISTS idx_recipes_created_at ON public.recipes(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_recipes_slug ON public.recipes(slug);

-- Full-text search index
CREATE INDEX IF NOT EXISTS idx_recipes_search ON public.recipes USING gin(
  to_tsvector('english', coalesce(title, '') || ' ' || coalesce(description, '') || ' ' || coalesce(notes, ''))
);

-- Trigger to auto-update updated_at
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS recipes_updated_at ON public.recipes;
CREATE TRIGGER recipes_updated_at
  BEFORE UPDATE ON public.recipes
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at();

-- ============================================================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================================================

-- Enable RLS
ALTER TABLE public.recipes ENABLE ROW LEVEL SECURITY;

-- Policy: Anyone can read recipes (public browse)
CREATE POLICY "recipes_select_public" ON public.recipes
  FOR SELECT
  USING (true);

-- Policy: Authenticated users can insert their own recipes
CREATE POLICY "recipes_insert_authenticated" ON public.recipes
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = created_by);

-- Policy: Users can only update their own recipes
CREATE POLICY "recipes_update_own" ON public.recipes
  FOR UPDATE
  TO authenticated
  USING (auth.uid() = created_by)
  WITH CHECK (auth.uid() = created_by);

-- Policy: Users can only delete their own recipes
CREATE POLICY "recipes_delete_own" ON public.recipes
  FOR DELETE
  TO authenticated
  USING (auth.uid() = created_by);

-- ============================================================================
-- HELPER FUNCTIONS
-- ============================================================================

-- Function to generate a unique slug from title
CREATE OR REPLACE FUNCTION generate_recipe_slug(title TEXT)
RETURNS TEXT AS $$
DECLARE
  base_slug TEXT;
  new_slug TEXT;
  counter INTEGER := 0;
BEGIN
  -- Normalize: lowercase, replace spaces/special chars with hyphens
  base_slug := lower(regexp_replace(title, '[^a-zA-Z0-9]+', '-', 'g'));
  base_slug := regexp_replace(base_slug, '^-|-$', '', 'g');  -- Trim leading/trailing hyphens
  base_slug := substring(base_slug from 1 for 60);  -- Limit length
  
  new_slug := base_slug;
  
  -- Check for uniqueness, append counter if needed
  WHILE EXISTS (SELECT 1 FROM public.recipes WHERE slug = new_slug) LOOP
    counter := counter + 1;
    new_slug := base_slug || '-' || counter;
  END LOOP;
  
  RETURN new_slug;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- VERIFICATION QUERIES (run these to confirm RLS works)
-- ============================================================================
/*
-- As anon user: should see all recipes
SELECT * FROM recipes LIMIT 5;

-- As anon user: should fail (no permission)
INSERT INTO recipes (slug, title) VALUES ('test', 'Test Recipe');

-- After logging in as a user:
-- This should succeed (inserting with own user id)
INSERT INTO recipes (slug, title, created_by) 
VALUES ('my-recipe', 'My Recipe', auth.uid());

-- This should fail (trying to insert as different user)
INSERT INTO recipes (slug, title, created_by) 
VALUES ('fake-recipe', 'Fake', 'some-other-uuid');

-- Update own recipe: should work
UPDATE recipes SET title = 'Updated' WHERE created_by = auth.uid();

-- Update someone else's recipe: should affect 0 rows
UPDATE recipes SET title = 'Hacked' WHERE created_by != auth.uid();
*/
