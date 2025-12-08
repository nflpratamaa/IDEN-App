-- Migration: Update quiz weight constraint from 0-10 to 0-100
-- Filename: update_quiz_weight_constraint.sql
-- Date: 2025-12-08

-- Step 1: Drop existing constraint
ALTER TABLE quizzes 
DROP CONSTRAINT IF EXISTS quizzes_weight_check;

-- Step 2: Add new constraint with range 0-100
ALTER TABLE quizzes 
ADD CONSTRAINT quizzes_weight_check 
CHECK (weight >= 0 AND weight <= 100);

-- Step 3: Update default value (optional, tetap 1)
ALTER TABLE quizzes 
ALTER COLUMN weight SET DEFAULT 1;

-- Verify constraint
SELECT 
    con.conname AS constraint_name,
    pg_get_constraintdef(con.oid) AS constraint_definition
FROM 
    pg_constraint con
    INNER JOIN pg_class rel ON rel.oid = con.conrelid
WHERE 
    rel.relname = 'quizzes' 
    AND con.conname = 'quizzes_weight_check';
