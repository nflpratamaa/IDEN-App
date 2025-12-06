-- ====================================================================
-- Add profile_image_url column to users table
-- ====================================================================
-- Purpose: Store URL to user's profile photo from Supabase Storage
-- Migration: Add missing column for profile photo feature
-- ====================================================================

-- Add profile_image_url column
ALTER TABLE users 
ADD COLUMN IF NOT EXISTS profile_image_url TEXT;

-- Add comment
COMMENT ON COLUMN users.profile_image_url IS 'URL to user profile photo stored in Supabase Storage (bucket: avatars)';

-- Verify column was added
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'users' AND column_name = 'profile_image_url';

-- ====================================================================
-- Instructions:
-- ====================================================================
-- 1. Run this script in Supabase SQL Editor
-- 2. Verify column was added with the SELECT query above
-- 3. Try upload foto profil lagi dari aplikasi
-- ====================================================================
