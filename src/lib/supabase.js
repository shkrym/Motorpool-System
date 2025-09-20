// src/lib/supabase.js
import { createClient } from '@supabase/supabase-js'

// Read values from your .env file
const supabaseUrl = import.meta.env.VITE_SUPABASE_URL
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY

// Create the client
export const supabase = createClient(supabaseUrl, supabaseAnonKey)
