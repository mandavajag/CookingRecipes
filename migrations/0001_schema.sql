-- Kitchen App D1 Schema
-- Run: wrangler d1 execute cooking_recipes --file=./migrations/0001_schema.sql

-- Users table for admin authentication
CREATE TABLE IF NOT EXISTS users (
  id TEXT PRIMARY KEY DEFAULT (lower(hex(randomblob(16)))),
  email TEXT UNIQUE NOT NULL,
  password_hash TEXT NOT NULL,
  created_at TEXT DEFAULT (datetime('now'))
);

-- Recipes table
CREATE TABLE IF NOT EXISTS recipes (
  id TEXT PRIMARY KEY DEFAULT (lower(hex(randomblob(16)))),
  slug TEXT UNIQUE NOT NULL,
  title TEXT NOT NULL,
  cuisine TEXT DEFAULT 'Other',
  category TEXT DEFAULT '',
  description TEXT DEFAULT '',
  prep_time INTEGER DEFAULT 0,
  cook_time INTEGER DEFAULT 0,
  servings TEXT DEFAULT '',
  difficulty TEXT DEFAULT '',
  tags TEXT DEFAULT '[]',        -- JSON array stored as text
  columns TEXT DEFAULT '[]',     -- JSON array of ingredient groups
  steps TEXT DEFAULT '[]',       -- JSON array of steps
  notes TEXT DEFAULT '',
  video_link TEXT DEFAULT '',
  created_by TEXT,               -- references users.id (nullable for seed data)
  created_at TEXT DEFAULT (datetime('now')),
  updated_at TEXT DEFAULT (datetime('now'))
);

-- Indexes for common queries
CREATE INDEX IF NOT EXISTS idx_recipes_slug ON recipes(slug);
CREATE INDEX IF NOT EXISTS idx_recipes_cuisine ON recipes(cuisine);
CREATE INDEX IF NOT EXISTS idx_recipes_created_by ON recipes(created_by);
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
