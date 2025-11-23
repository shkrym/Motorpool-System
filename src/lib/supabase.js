// src/lib/supabase.js
import { createClient } from '@supabase/supabase-js'

// Read values from your .env file
const supabaseUrl = import.meta.env.VITE_SUPABASE_URL
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY

// Validate that environment variables exist
if (!supabaseUrl) {
  throw new Error(
    '❌ Missing VITE_SUPABASE_URL environment variable.\n' +
    'Please create a .env file in the root directory with:\n' +
    'VITE_SUPABASE_URL=your_supabase_url_here\n\n' +
    'You can find your Supabase URL in your Supabase project settings.'
  )
}

if (!supabaseAnonKey) {
  throw new Error(
    '❌ Missing VITE_SUPABASE_ANON_KEY environment variable.\n' +
    'Please create a .env file in the root directory with:\n' +
    'VITE_SUPABASE_ANON_KEY=your_supabase_anon_key_here\n\n' +
    'You can find your Supabase Anon Key in your Supabase project settings.'
  )
}

// Create the client (now we know values exist!)
export const supabase = createClient(supabaseUrl, supabaseAnonKey)
