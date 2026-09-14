# Kitchen 🍳

A beautiful recipe collection app with Supabase backend. Browse, create, and share recipes with a clean, modern interface.

**Live Demo:** Your GitHub Pages URL after deployment

## Features

- **Public Recipe Browsing** - Anyone can view and search recipes
- **User Authentication** - Sign in with email/password or magic link
- **Personal Recipe Management** - Create, edit, and delete your own recipes
- **Shareable URLs** - Each recipe has a unique URL for easy sharing
- **Ingredient Checklists** - Interactive checkboxes while cooking
- **Responsive Design** - Works great on mobile and desktop
- **Offline Fallback** - Falls back to local storage if Supabase is unavailable

## Quick Start

### 1. Create a Supabase Project

1. Go to [supabase.com](https://supabase.com) and create a free account
2. Create a new project (note your project URL and region)
3. Wait for the database to be provisioned (~2 minutes)

### 2. Run Database Migrations

1. Go to **SQL Editor** in your Supabase dashboard
2. Copy the contents of `supabase/migrations/001_create_recipes_table.sql` and run it
3. Copy the contents of `supabase/migrations/002_seed_recipes.sql` and run it to seed existing recipes

### 3. Enable Email Authentication

1. Go to **Authentication** → **Providers** in Supabase dashboard
2. Ensure **Email** provider is enabled
3. Configure email settings:
   - **Enable email confirmations**: Recommended for production
   - **Enable magic link login**: Yes (allows passwordless auth)

### 4. Get Your API Keys

1. Go to **Settings** → **API** in Supabase dashboard
2. Copy your:
   - **Project URL**: `https://YOUR_PROJECT_REF.supabase.co`
   - **anon/public key**: `sb_publishable_...` (safe for client-side)

### 5. Configure the App

The app reads from `config.js`. For a static GitHub Pages deploy, the default values are already configured. If you need to change them:

**Option A: Edit `config.js` directly** (simplest for static hosting)

```javascript
SUPABASE_URL: 'https://your-project-ref.supabase.co',
SUPABASE_ANON_KEY: 'sb_publishable_your_key_here',
```

**Option B: Use environment variables** (for build tools)

Set these in your `.env` file or CI/CD secrets:

```bash
NEXT_PUBLIC_SUPABASE_URL=https://your-project-ref.supabase.co
NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY=sb_publishable_your_key_here
```

> **Note:** The publishable/anon key is safe to commit. All security is enforced server-side via Row Level Security (RLS).

### 6. Deploy to GitHub Pages

**Option A: Direct Push (Simple)**

1. Push changes to your `main` branch
2. Go to **Settings** → **Pages** in your GitHub repo
3. Set source to "Deploy from a branch" → `main` → `/ (root)`
4. Your site will be live at `https://username.github.io/repo-name/`

**Option B: GitHub Actions (Automated)**

Create `.github/workflows/deploy.yml`:

```yaml
name: Deploy to GitHub Pages

on:
  push:
    branches: [main]

permissions:
  contents: read
  pages: write
  id-token: write

jobs:
  deploy:
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/configure-pages@v4
      - uses: actions/upload-pages-artifact@v3
        with:
          path: '.'
      - uses: actions/deploy-pages@v4
        id: deployment
```

## Security

### Row Level Security (RLS)

The database is protected by Supabase's Row Level Security:

| Operation | Policy |
|-----------|--------|
| **SELECT** | Public - anyone can read recipes |
| **INSERT** | Authenticated only - `created_by` set by server trigger |
| **UPDATE** | Owner only - `auth.uid() = created_by` |
| **DELETE** | Owner only - `auth.uid() = created_by` |

### Ownership Protection

- **Server-enforced ownership**: A `BEFORE INSERT` trigger automatically sets `created_by` to `auth.uid()`. The client cannot spoof ownership.
- **Immutable ownership**: A `BEFORE UPDATE` trigger prevents changing `created_by` after creation.
- **Orphaned recipes**: If a user is deleted, their recipes become orphaned (`created_by = NULL`). These recipes remain readable but are no longer editable by anyone except via service_role. This preserves content; use `ON DELETE CASCADE` instead if you prefer deleting user content.

### Seed Data

Recipes from `002_seed_recipes.sql` have `created_by = NULL` (no owner). This is intentional:
- They are "community" recipes that everyone can read
- No regular user can edit them (RLS requires `auth.uid() = created_by`)
- Only service_role (admin backend) can modify them

To transfer a seed recipe to a user: `UPDATE recipes SET created_by = 'user-uuid' WHERE slug = 'recipe-slug'` (requires service_role key).

### API Keys

- ✅ **anon/public key**: Safe to expose in client code. All security is enforced by RLS.
- ❌ **service_role key**: NEVER expose this. It bypasses RLS.

### Local Storage Fallback

By default, `ENABLE_LOCAL_STORAGE_FALLBACK` is **disabled** for production security. When enabled:
- Local recipes appear in the UI alongside server recipes
- Local data does NOT bypass server-side checks (you still can't edit others' recipes)
- Useful for offline-first or demo scenarios

Set `ENABLE_LOCAL_STORAGE_FALLBACK: true` in `config.js` to enable.

## Development

### Local Development

1. Clone the repository
2. Update `config.js` with your Supabase credentials
3. Serve the files locally:
   ```bash
   # Python
   python -m http.server 8000
   
   # Node.js
   npx serve
   
   # Or just open index.html in a browser
   ```
4. Open `http://localhost:8000`

### Project Structure

```
├── index.html          # Main app (HTML + embedded JS)
├── styles.css          # All styles
├── config.js           # Supabase configuration
├── recipes.json        # Legacy recipe data (for fallback)
├── .env.example        # Environment variable template
├── supabase/
│   └── migrations/
│       ├── 001_create_recipes_table.sql  # Schema + RLS policies
│       └── 002_seed_recipes.sql          # Initial recipe data
└── README.md
```

## Database Schema

```sql
recipes (
  id            UUID PRIMARY KEY,
  slug          TEXT UNIQUE NOT NULL,     -- URL-friendly identifier
  title         TEXT NOT NULL,
  cuisine       TEXT DEFAULT 'Other',
  category      TEXT DEFAULT '',
  description   TEXT DEFAULT '',
  prep_time     INTEGER DEFAULT 0,
  cook_time     INTEGER DEFAULT 0,
  servings      TEXT DEFAULT '',
  difficulty    TEXT DEFAULT '',
  tags          TEXT[] DEFAULT '{}',
  columns       JSONB DEFAULT '[]',       -- Ingredient groups
  steps         TEXT[] DEFAULT '{}',
  notes         TEXT DEFAULT '',
  video_link    TEXT DEFAULT '',
  created_by    UUID REFERENCES auth.users(id),
  created_at    TIMESTAMPTZ DEFAULT now(),
  updated_at    TIMESTAMPTZ DEFAULT now()
)
```

## Verifying RLS Works

Run these queries in Supabase SQL Editor to verify security:

```sql
-- As anonymous user: should return recipes
SELECT * FROM recipes LIMIT 5;

-- As anonymous user: should fail with permission denied
INSERT INTO recipes (slug, title) VALUES ('test', 'Test');
```

After signing in via the app:

```sql
-- Should succeed (your own recipe)
INSERT INTO recipes (slug, title, created_by) 
VALUES ('my-recipe', 'My Recipe', auth.uid());

-- Should fail (different user's recipe)
UPDATE recipes SET title = 'Hacked' WHERE created_by != auth.uid();
```

## Troubleshooting

### "Supabase not configured" warning

- Check that `config.js` has your actual Supabase URL (not the placeholder)
- Verify the URL format: `https://YOUR_PROJECT_REF.supabase.co`

### Authentication not working

- Ensure Email provider is enabled in Supabase dashboard
- Check that your site URL is added to **Authentication** → **URL Configuration** → **Site URL**
- For magic links, ensure **Redirect URLs** includes your GitHub Pages URL

### RLS errors

- Verify you ran both migration files in order
- Check **Authentication** → **Policies** to see active policies
- Enable RLS debugging: `ALTER TABLE recipes SET (security_invoker = on);`

### CORS errors

- Your Supabase project automatically allows requests from any origin
- If issues persist, check **Settings** → **API** → **CORS**

## Customization

### Adding New Cuisines

Edit the `ACCENTS` object in `index.html` to add accent colors for new cuisine types:

```javascript
const ACCENTS = {
  "Your Cuisine": "#hexcolor",
  // ...
};
```

### Changing Auth Providers

Supabase supports many auth providers. Edit the auth modal in `index.html` and add OAuth buttons that call:

```javascript
supabase.auth.signInWithOAuth({ provider: 'google' })
```

## License

MIT License - feel free to use this for your own recipe collection!

---

Built with 💚 using [Supabase](https://supabase.com) and vanilla JavaScript.
