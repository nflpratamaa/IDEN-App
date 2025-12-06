-- ====================================================================
-- Supabase Storage Setup for Content Images (Articles & Drugs)
-- ====================================================================
-- Bucket: content-images
-- Purpose: Store images for articles and drugs in content management
-- Access: Public read, authenticated users can upload/update/delete
-- ====================================================================

-- Drop existing policies if re-running
DROP POLICY IF EXISTS "Allow authenticated uploads to content-images" ON storage.objects;
DROP POLICY IF EXISTS "Allow public downloads from content-images" ON storage.objects;
DROP POLICY IF EXISTS "Allow authenticated updates to content-images" ON storage.objects;
DROP POLICY IF EXISTS "Allow authenticated deletes from content-images" ON storage.objects;

-- ====================================================================
-- Create RLS Policies for 'content-images' bucket
-- ====================================================================

-- Policy 1: Authenticated users can INSERT to content-images bucket
CREATE POLICY "Allow authenticated uploads to content-images"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'content-images');

-- Policy 2: Public can SELECT from content-images bucket
CREATE POLICY "Allow public downloads from content-images"
ON storage.objects
FOR SELECT
TO public
USING (bucket_id = 'content-images');

-- Policy 3: Authenticated users can UPDATE in content-images bucket
CREATE POLICY "Allow authenticated updates to content-images"
ON storage.objects
FOR UPDATE
TO authenticated
USING (bucket_id = 'content-images')
WITH CHECK (bucket_id = 'content-images');

-- Policy 4: Authenticated users can DELETE from content-images bucket
CREATE POLICY "Allow authenticated deletes from content-images"
ON storage.objects
FOR DELETE
TO authenticated
USING (bucket_id = 'content-images');

-- ====================================================================
-- Verification Query
-- ====================================================================

SELECT 
  policyname, 
  cmd
FROM pg_policies 
WHERE tablename = 'objects' 
  AND policyname LIKE '%content-images%'
ORDER BY policyname;

-- Expected output: 4 policies
-- 1. Allow authenticated deletes from content-images (DELETE)
-- 2. Allow authenticated updates to content-images (UPDATE)
-- 3. Allow authenticated uploads to content-images (INSERT)
-- 4. Allow public downloads from content-images (SELECT)

-- ====================================================================
-- Instructions:
-- ====================================================================
-- 1. Buat bucket 'content-images' di Supabase Dashboard → Storage → New Bucket
-- 2. Set bucket sebagai PUBLIC (centang "Public bucket")
-- 3. Run script ini di SQL Editor
-- 4. Verify dengan query di atas - harus ada 4 policies
-- ====================================================================
