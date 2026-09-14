-- Kitchen Recipes Schema
-- Run this in your Supabase SQL editor: https://supabase.com/dashboard/project/YOUR_PROJECT/sql

-- ============================================================================
-- TABLE DEFINITION
-- ============================================================================

-- Recipes table
-- Note: Using gen_random_uuid() (built-in) instead of uuid-ossp extension
CREATE TABLE IF NOT EXISTS public.recipes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- Human-readable slug for URLs (UNIQUE constraint auto-creates index)
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
  -- ON DELETE SET NULL: If user is deleted, recipe becomes orphaned (read-only, no owner).
  -- This preserves recipe content. Use CASCADE if you prefer deleting user's recipes.
  created_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- ============================================================================
-- INDEXES
-- ============================================================================
-- Note: slug already has a unique index from the UNIQUE constraint

CREATE INDEX IF NOT EXISTS idx_recipes_cuisine ON public.recipes(cuisine);
CREATE INDEX IF NOT EXISTS idx_recipes_created_by ON public.recipes(created_by);
CREATE INDEX IF NOT EXISTS idx_recipes_created_at ON public.recipes(created_at DESC);

-- Full-text search index
CREATE INDEX IF NOT EXISTS idx_recipes_search ON public.recipes USING gin(
  to_tsvector('english', coalesce(title, '') || ' ' || coalesce(description, '') || ' ' || coalesce(notes, ''))
);

-- ============================================================================
-- TRIGGERS: Ownership & Timestamps
-- ============================================================================

-- Trigger function: Auto-update updated_at timestamp
-- SET search_path = public to prevent mutable search_path attacks
CREATE OR REPLACE FUNCTION public.update_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = public
AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS recipes_updated_at ON public.recipes;
CREATE TRIGGER recipes_updated_at
  BEFORE UPDATE ON public.recipes
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at();

-- Trigger function: Force created_by to auth.uid() on INSERT
-- This prevents JWT clients from spoofing ownership while allowing
-- service_role / SQL editor to set ownership explicitly (e.g., for seeds)
CREATE OR REPLACE FUNCTION public.set_recipe_owner()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = public
AS $$
BEGIN
  -- Only override created_by when there's an authenticated JWT user
  -- This locks down API clients but allows service_role to set ownership
  IF auth.uid() IS NOT NULL THEN
    NEW.created_by := auth.uid();
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS recipes_set_owner ON public.recipes;
CREATE TRIGGER recipes_set_owner
  BEFORE INSERT ON public.recipes
  FOR EACH ROW
  EXECUTE FUNCTION public.set_recipe_owner();

-- Trigger function: Prevent changing created_by on UPDATE (immutable ownership)
-- Only enforced for JWT clients; service_role can transfer ownership if needed
CREATE OR REPLACE FUNCTION public.protect_recipe_owner()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = public
AS $$
BEGIN
  -- Only enforce immutability for authenticated JWT users
  -- service_role (auth.uid() IS NULL) can update ownership for admin tasks
  IF auth.uid() IS NOT NULL
     AND OLD.created_by IS DISTINCT FROM NEW.created_by THEN
    RAISE EXCEPTION 'Cannot change recipe ownership (created_by is immutable)';
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS recipes_protect_owner ON public.recipes;
CREATE TRIGGER recipes_protect_owner
  BEFORE UPDATE ON public.recipes
  FOR EACH ROW
  EXECUTE FUNCTION public.protect_recipe_owner();

-- ============================================================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================================================

ALTER TABLE public.recipes ENABLE ROW LEVEL SECURITY;

-- Policy: Anyone can read recipes (public browse)
CREATE POLICY "recipes_select_public" ON public.recipes
  FOR SELECT
  USING (true);

-- Policy: Authenticated users can insert recipes
-- Note: created_by is set by trigger, not client. WITH CHECK ensures trigger ran correctly.
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
-- EXPLICIT GRANTS
-- ============================================================================

-- Revoke all first to ensure clean state
REVOKE ALL ON public.recipes FROM anon, authenticated;

-- Grant SELECT to both anon and authenticated (public read)
GRANT SELECT ON public.recipes TO anon;
GRANT SELECT ON public.recipes TO authenticated;

-- Grant write operations only to authenticated users
GRANT INSERT, UPDATE, DELETE ON public.recipes TO authenticated;

-- ============================================================================
-- HELPER FUNCTIONS
-- ============================================================================

-- Function to generate a unique slug from title
-- SET search_path = public to prevent mutable search_path attacks
CREATE OR REPLACE FUNCTION public.generate_recipe_slug(p_title TEXT)
RETURNS TEXT
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = public
AS $$
DECLARE
  base_slug TEXT;
  new_slug TEXT;
  counter INTEGER := 0;
BEGIN
  -- Normalize: lowercase, replace spaces/special chars with hyphens
  base_slug := lower(regexp_replace(p_title, '[^a-zA-Z0-9]+', '-', 'g'));
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
$$;

-- ============================================================================
-- VERIFICATION QUERIES (run these to confirm security works)
-- ============================================================================
/*
-- As anon user: should see all recipes
SELECT * FROM recipes LIMIT 5;

-- As anon user: should fail (no INSERT permission)
INSERT INTO recipes (slug, title) VALUES ('test', 'Test Recipe');

-- After logging in as authenticated user:

-- This should succeed. Note: created_by is IGNORED - trigger sets it to auth.uid()
INSERT INTO recipes (slug, title) VALUES ('my-recipe', 'My Recipe');

-- Verify ownership was set correctly
SELECT id, title, created_by FROM recipes WHERE slug = 'my-recipe';

-- Try to spoof ownership (should be ignored by trigger, set to your ID instead)
INSERT INTO recipes (slug, title, created_by) 
VALUES ('spoofed-recipe', 'Spoofed', '00000000-0000-0000-0000-000000000000');
-- Check: created_by should be YOUR user ID, not the fake UUID

-- Update own recipe: should work
UPDATE recipes SET title = 'Updated Title' WHERE slug = 'my-recipe';

-- Try to change ownership: should FAIL with exception
UPDATE recipes SET created_by = '00000000-0000-0000-0000-000000000000' WHERE slug = 'my-recipe';
-- Error: "Cannot change recipe ownership (created_by is immutable)"

-- Update someone else's recipe: should affect 0 rows (RLS blocks it)
UPDATE recipes SET title = 'Hacked' WHERE created_by != auth.uid();

-- Delete own recipe: should work
DELETE FROM recipes WHERE slug = 'my-recipe';

-- SEED DATA NOTE:
-- Recipes from 002_seed_recipes.sql have created_by = NULL (no owner).
-- These are "system" recipes: readable by all, editable by none (except service_role).
-- This is intentional - seed data is read-only community content.
*/
