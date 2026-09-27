# Kitchen 🍳

A beautiful recipe collection app powered by Cloudflare Pages + D1. Browse, create, and share recipes with a clean, modern interface.

## Features

- **Public Recipe Browsing** - Anyone can view and search recipes
- **Admin Authentication** - Sign in with email/password to manage recipes
- **Personal Recipe Management** - Create, edit, and delete your own recipes
- **Shareable URLs** - Each recipe has a unique URL for easy sharing
- **Ingredient Checklists** - Interactive checkboxes while cooking
- **Responsive Design** - Works great on mobile and desktop

## Stack

- **Hosting**: Cloudflare Pages (static site + Functions)
- **Database**: Cloudflare D1 (SQLite)
- **Auth**: Cookie-based sessions with PBKDF2 password hashing

## Quick Start

### Prerequisites

- [Cloudflare account](https://dash.cloudflare.com/sign-up)
- [Wrangler CLI](https://developers.cloudflare.com/workers/wrangler/install-and-update/)

```bash
npm install -g wrangler
wrangler login
```

### 1. Create D1 Database

The D1 database is already configured in `wrangler.toml`:
- **Name**: `cooking_recipes`
- **ID**: `6c74ff80-daf7-4766-958a-4977e584ccf0`
- **Binding**: `DB`

If you need to create your own database:

```bash
wrangler d1 create cooking_recipes
# Update wrangler.toml with the new database_id
```

### 2. Run Migrations

Apply the database schema:

```bash
wrangler d1 execute cooking_recipes --file=./migrations/0001_schema.sql
```

### 3. Seed Data

Seed the recipes:

```bash
wrangler d1 execute cooking_recipes --file=./migrations/0002_seed_recipes.sql
```

Seed the admin user:

```bash
wrangler d1 execute cooking_recipes --file=./migrations/0003_seed_admin.sql
```

**Admin credentials:**
- Email: `mandavajag@gmail.com`
- Password: `welcome1234`

### 4. Set SESSION_SECRET

The `SESSION_SECRET` is used to sign session cookies. **Never commit this to git.**

**For local development:**

```bash
# Create a .dev.vars file (gitignored)
echo 'SESSION_SECRET="your-random-secret-at-least-32-chars"' > .dev.vars
```

**For production (Cloudflare Dashboard):**

1. Go to your Pages project → **Settings** → **Environment variables**
2. Add a new variable:
   - Variable name: `SESSION_SECRET`
   - Value: A random string (32+ characters)
   - Select "Encrypt" for security

Or via CLI:

```bash
wrangler pages secret put SESSION_SECRET
# Enter your secret when prompted
```

Generate a random secret:

```bash
openssl rand -base64 32
```

### 5. Deploy to Pages

**Option A: GitHub Integration (Recommended)**

1. Push this repo to GitHub
2. Go to [Cloudflare Dashboard](https://dash.cloudflare.com) → Pages → Create a project
3. Connect your GitHub repo
4. Configure:
   - Build command: (leave empty - static site)
   - Build output directory: `/`
5. Add the D1 binding:
   - Go to project **Settings** → **Functions** → **D1 database bindings**
   - Variable name: `DB`
   - D1 database: `cooking_recipes`
6. Add the `SESSION_SECRET` environment variable

**Option B: Direct Upload**

```bash
wrangler pages deploy .
```

Then configure D1 binding and SESSION_SECRET in the dashboard.

### 6. Local Development

```bash
# Install dependencies (for wrangler)
npm install

# Start local dev server with D1
wrangler pages dev . --d1=DB=cooking_recipes
```

Open http://localhost:8788

## Project Structure

```
├── index.html              # Main app (HTML + embedded JS)
├── styles.css              # All styles
├── wrangler.toml           # Cloudflare configuration
├── functions/              # Pages Functions (API)
│   ├── _shared/
│   │   └── auth.js         # Auth utilities
│   └── api/
│       ├── recipes/
│       │   ├── index.js    # GET/POST /api/recipes
│       │   └── [slug].js   # GET/PUT/DELETE /api/recipes/:slug
│       └── auth/
│           ├── login.js    # POST /api/auth/login
│           ├── logout.js   # POST /api/auth/logout
│           └── me.js       # GET /api/auth/me
├── migrations/
│   ├── 0001_schema.sql     # Database schema
│   ├── 0002_seed_recipes.sql   # Recipe seed data
│   └── 0003_seed_admin.sql     # Admin user seed
└── README.md
```

## API Endpoints

| Endpoint | Method | Auth | Description |
|----------|--------|------|-------------|
| `/api/recipes` | GET | Public | List all recipes |
| `/api/recipes` | POST | Required | Create a recipe |
| `/api/recipes/:slug` | GET | Public | Get recipe by slug |
| `/api/recipes/:slug` | PUT | Owner | Update recipe |
| `/api/recipes/:slug` | DELETE | Owner | Delete recipe |
| `/api/auth/login` | POST | - | Sign in |
| `/api/auth/logout` | POST | - | Sign out |
| `/api/auth/me` | GET | - | Get current user |

## Security

### Authentication

- Passwords are hashed with PBKDF2-SHA256 (100,000 iterations)
- Sessions use HMAC-SHA256 signed cookies
- Cookies are HttpOnly, Secure, SameSite=Lax

### Authorization

- **Public**: Anyone can read recipes
- **Admin**: Only authenticated users can create recipes
- **Owner**: Users can only edit/delete their own recipes
- Seed recipes (created_by = NULL) cannot be edited by anyone

### Secrets

- `SESSION_SECRET`: **Required** - Set via environment variable, never in code
- No API keys or passwords in the repository

## Database Schema

```sql
-- Users (admin accounts)
users (
  id TEXT PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  password_hash TEXT NOT NULL,
  created_at TEXT
)

-- Recipes
recipes (
  id TEXT PRIMARY KEY,
  slug TEXT UNIQUE NOT NULL,
  title TEXT NOT NULL,
  cuisine TEXT DEFAULT 'Other',
  category TEXT DEFAULT '',
  description TEXT DEFAULT '',
  prep_time INTEGER DEFAULT 0,
  cook_time INTEGER DEFAULT 0,
  servings TEXT DEFAULT '',
  difficulty TEXT DEFAULT '',
  tags TEXT DEFAULT '[]',      -- JSON array
  columns TEXT DEFAULT '[]',   -- JSON array (ingredient groups)
  steps TEXT DEFAULT '[]',     -- JSON array
  notes TEXT DEFAULT '',
  video_link TEXT DEFAULT '',
  created_by TEXT,             -- FK to users.id
  created_at TEXT,
  updated_at TEXT
)
```

## Customization

### Adding New Cuisines

Edit the `ACCENTS` object in `index.html` to add accent colors:

```javascript
const ACCENTS = {
  "Your Cuisine": "#hexcolor",
  // ...
};
```

### Changing Admin Password

Generate a new PBKDF2 hash:

```javascript
// Run in Node.js
const crypto = require('crypto');
const password = 'your-new-password';
const salt = crypto.randomBytes(16);
crypto.pbkdf2(password, salt, 100000, 32, 'sha256', (err, key) => {
  console.log(`pbkdf2-sha256$100000$${salt.toString('base64')}$${key.toString('base64')}`);
});
```

Update in D1:

```sql
UPDATE users SET password_hash = 'new-hash-here' WHERE email = 'your@email.com';
```

## Troubleshooting

### "Connection issue" on load

- Check that D1 is bound correctly in Pages settings
- Verify migrations were applied

### Can't sign in

- Verify `SESSION_SECRET` is set in environment variables
- Check that admin user was seeded

### API returns 500 errors

- Check Pages Functions logs in Cloudflare Dashboard
- Verify D1 binding name matches `DB`

## License

MIT License - feel free to use this for your own recipe collection!

---

Built with 💚 using [Cloudflare Pages](https://pages.cloudflare.com) + [D1](https://developers.cloudflare.com/d1/)
