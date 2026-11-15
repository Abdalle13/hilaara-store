import fs from 'fs';

const schema = fs.readFileSync('./supabase/migrations/20261112000000_initial_schema.sql', 'utf8');
const seed = fs.readFileSync('./supabase_seed.sql', 'utf8');

const combined = [
  '-- ============================================================================',
  '-- HILAARA STORE — COMPLETE DATABASE SETUP (SCHEMA + REAL PRODUCTS SEED)',
  '-- Run this in the Supabase SQL Editor:',
  '-- https://supabase.com/dashboard/project/nloetsqpdloapgvzqkqn/sql/new',
  '-- ============================================================================',
  '',
  schema,
  '',
  '-- ============================================================================',
  '-- 11. REAL LUXURY SOMALI FASHION SEED DATA',
  '-- ============================================================================',
  '',
  seed,
  '',
  '-- ============================================================================',
  '-- 12. ADMIN ROLE ASSIGNMENT HELPER',
  '-- After registering in the app, run the following to grant admin access:',
  "-- UPDATE public.profiles SET role = 'admin' WHERE email = 'abdallehussein8@gmail.com';",
  '-- ============================================================================',
  ''
].join('\n');

fs.writeFileSync('./supabase_complete_setup.sql', combined, 'utf8');
console.log('Successfully created supabase_complete_setup.sql. Size: ' + combined.length + ' bytes');

