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
 */

const KitchenConfig = (() => {
  // Try to read from window config (set by build/CI) or use defaults
  // For static sites, you can inject these via a build step or edit directly
  const env = window.__KITCHEN_ENV__ || {};

  return {
    // Supabase project URL
    // Env var: NEXT_PUBLIC_SUPABASE_URL (or VITE_SUPABASE_URL for Vite builds)
    SUPABASE_URL: env.NEXT_PUBLIC_SUPABASE_URL || env.SUPABASE_URL || 'https://mgmaxspuazxaywskopze.supabase.co',

    // Supabase anonymous/publishable key (safe for client-side)
    // Env var: NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY
    // This key is safe to commit - all security is enforced by RLS on the server
    SUPABASE_ANON_KEY: env.NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY || env.SUPABASE_ANON_KEY || 'sb_publishable_QcKiacF4OJRhkShAkAzsYw_7_l5ypJI',

    // App settings
    APP_NAME: 'Kitchen',
    
    // Feature flags
    // SECURITY: Local storage fallback is DISABLED by default for production.
    // When enabled, local recipes can appear alongside server recipes, but local
    // data does NOT bypass server-side ownership checks (RLS still enforces auth).
    // Set to true only for offline-first/demo scenarios.
    ENABLE_LOCAL_STORAGE_FALLBACK: env.ENABLE_LOCAL_STORAGE_FALLBACK || false,
    DEBUG_MODE: env.DEBUG_MODE || false,

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
