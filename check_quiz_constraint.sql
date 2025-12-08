-- Query untuk cek constraint quizzes_weight_check
SELECT 
    con.conname AS constraint_name,
    pg_get_constraintdef(con.oid) AS constraint_definition
FROM 
    pg_constraint con
    INNER JOIN pg_class rel ON rel.oid = con.conrelid
WHERE 
    rel.relname = 'quizzes' 
    AND con.conname = 'quizzes_weight_check';

-- Atau cek semua constraints di table quizzes
SELECT 
    con.conname AS constraint_name,
    con.contype AS constraint_type,
    pg_get_constraintdef(con.oid) AS constraint_definition
FROM 
    pg_constraint con
    INNER JOIN pg_class rel ON rel.oid = con.conrelid
WHERE 
    rel.relname = 'quizzes'
ORDER BY con.conname;
