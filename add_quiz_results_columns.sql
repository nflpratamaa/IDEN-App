-- ================================
-- Migration: Add missing columns to quiz_results table
-- Date: 2025-12-08
-- Purpose: Fix quiz result save functionality
-- ================================

-- Add quiz_id column (optional, for tracking which quiz was taken)
ALTER TABLE quiz_results 
ADD COLUMN IF NOT EXISTS quiz_id TEXT;

-- Add max_score column (to store the maximum possible score)
ALTER TABLE quiz_results 
ADD COLUMN IF NOT EXISTS max_score INTEGER;

-- Add percentage column (to store the percentage score)
ALTER TABLE quiz_results 
ADD COLUMN IF NOT EXISTS percentage INTEGER CHECK (percentage >= 0 AND percentage <= 100);

-- Add comment to document the changes
COMMENT ON COLUMN quiz_results.quiz_id IS 'Optional identifier for which quiz/assessment was taken';
COMMENT ON COLUMN quiz_results.max_score IS 'Maximum possible score for this quiz';
COMMENT ON COLUMN quiz_results.percentage IS 'Percentage score (0-100)';

-- Optional: Update existing records to have percentage calculated
UPDATE quiz_results 
SET percentage = ROUND((total_score::DECIMAL / NULLIF(max_score, 0)) * 100)
WHERE max_score IS NOT NULL AND max_score > 0 AND percentage IS NULL;
