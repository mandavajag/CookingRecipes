/**
 * Kitchen App Configuration
 * 
 * For GitHub Pages deployment:
 * 1. Fork/clone this repo
 * 2. Create a Supabase project at https://supabase.com
 * 3. Run the migrations in supabase/migrations/*.sql
 * 4. Copy your project URL and anon key from Settings > API
 * 5. Either:
 *    a) Edit this file directly with your values, OR
 *    b) For GitHub Pages: use environment variables in your CI/CD
 * 
 * SECURITY NOTE: The anon/publishable key is safe to expose in client code.
 * Row Level Security (RLS) enforces all access rules server-side.
 * 
 * KEY TYPES:
 * - Legacy JWT anon key (eyJ...): Full supabase-js compatibility, recommended for CDN usage
 * - Publishable key (sb_publishable_...): Newer format, may have edge cases with CDN builds
 * 
 * If using supabase-js from CDN (jsdelivr), prefer the legacy JWT format from
 * Supabase Dashboard > Settings > API > Project API keys > anon/public
 */

const KitchenConfig = (() => {
  // Try to read from window config (set by build/CI) or use defaults
  // For static sites, you can inject these via a build step or edit directly
  const env = window.__KITCHEN_ENV__ || {};

  return {
    // Supabase project URL
    // Env var: NEXT_PUBLIC_SUPABASE_URL (or VITE_SUPABASE_URL for Vite builds)
    SUPABASE_URL: env.NEXT_PUBLIC_SUPABASE_URL || env.SUPABASE_URL || 'https://mgmaxspuazxaywskopze.supabase.co',

    // Supabase anonymous key (safe for client-side)
    // Using the legacy JWT format for maximum CDN compatibility with supabase-js@2
    // Get this from: Supabase Dashboard > Settings > API > Project API keys > anon/public
    // Alternate: sb_publishable_QcKiacF4OJRhkShAkAzsYw_7_l5ypJI (may have CDN edge cases)
    SUPABASE_ANON_KEY: env.NEXT_PUBLIC_SUPABASE_ANON_KEY || env.SUPABASE_ANON_KEY || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1nbWF4c3B1YXp4YXl3c2tvcHplIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODkzNDIwMDUsImV4cCI6MjEwNDkxODAwNX0.5nF6MwJajdQ0zPKlKM8UuA6ROmGVDePkNmxgEhJMOvw',

    // App settings
    APP_NAME: 'Kitchen',
    
    // Feature flags
    DEBUG_MODE: env.DEBUG_MODE || false,
    
    // Data model:
    // - Supabase is the source of truth for all write operations
    // - Saves FAIL LOUDLY if Supabase rejects or is unavailable (no silent fallback)
    // - When offline, shows read-only cached copy of last successful DB fetch
    // - Cache is stored in localStorage (kitchen.recipes.dbCache) for offline viewing

    // Check if Supabase is properly configured
    isConfigured() {
      return this.SUPABASE_URL && 
             !this.SUPABASE_URL.includes('YOUR_PROJECT') &&
             this.SUPABASE_ANON_KEY &&
             this.SUPABASE_ANON_KEY.length > 20;
    }
  };
})();

// Freeze to prevent accidental modification
Object.freeze(KitchenConfig);

// Attach to window for script-tag usage (top-level const isn't on window)
window.KitchenConfig = KitchenConfig;
