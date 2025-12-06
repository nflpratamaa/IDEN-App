-- ====================================================================
-- Supabase Storage Setup for Profile Avatars - SIMPLIFIED
-- ====================================================================
-- Bucket: avatars
-- Purpose: Store user profile photos
-- Access: Public read, authenticated users can upload/update/delete
-- ====================================================================

-- NOTE: RLS on storage.objects is already enabled by default in Supabase
-- We just need to create the policies

-- ====================================================================
-- Step 1: Drop existing policies (if any)
-- ====================================================================
DROP POLICY IF EXISTS "Users can upload own avatar" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can upload avatars" ON storage.objects;
DROP POLICY IF EXISTS "Anyone can view avatars" ON storage.objects;
DROP POLICY IF EXISTS "Users can update own avatar" ON storage.objects;
DROP POLICY IF EXISTS "Users can delete own avatar" ON storage.objects;

-- ====================================================================
-- Step 2: Create new simplified policies
-- ====================================================================

-- Policy 1: Authenticated users can INSERT to avatars bucket
CREATE POLICY "Allow authenticated uploads to avatars"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'avatars');

-- Policy 2: Public can SELECT from avatars bucket
CREATE POLICY "Allow public downloads from avatars"
ON storage.objects
FOR SELECT
TO public
USING (bucket_id = 'avatars');

-- Policy 3: Authenticated users can UPDATE in avatars bucket
CREATE POLICY "Allow authenticated updates to avatars"
ON storage.objects
FOR UPDATE
TO authenticated
USING (bucket_id = 'avatars')
WITH CHECK (bucket_id = 'avatars');

-- Policy 4: Authenticated users can DELETE from avatars bucket
CREATE POLICY "Allow authenticated deletes from avatars"
ON storage.objects
FOR DELETE
TO authenticated
USING (bucket_id = 'avatars');

-- ====================================================================
-- Verification Query
-- ====================================================================

-- Check if policies are created successfully
SELECT 
  policyname, 
  cmd,
  qual,
  with_check
FROM pg_policies 
WHERE tablename = 'objects' 
  AND policyname LIKE '%avatars%'
ORDER BY policyname;

-- Expected output: 4 policies
-- 1. Allow authenticated deletes from avatars (DELETE)
-- 2. Allow authenticated updates to avatars (UPDATE)
-- 3. Allow authenticated uploads to avatars (INSERT)
-- 4. Allow public downloads from avatars (SELECT)

-- ====================================================================
-- Instructions:
-- ====================================================================
-- 1. Buat bucket 'avatars' di Supabase Dashboard → Storage → New Bucket
-- 2. Set bucket sebagai PUBLIC (centang "Public bucket")
-- 3. Run SELURUH script ini di SQL Editor (termasuk DROP dan CREATE)
-- 4. Verify dengan query di atas - harus ada 4 policies
-- 5. Test upload dari aplikasi
-- ====================================================================
