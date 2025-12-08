-- Script untuk recalculate articles_read counter dari read_history
-- Jalankan di Supabase SQL Editor

-- Update articles_read counter untuk semua users berdasarkan read_history
UPDATE users
SET articles_read = (
  SELECT COUNT(DISTINCT article_id)
  FROM read_history
  WHERE read_history.user_id = users.id
);

-- Verify hasil
SELECT 
  u.name,
  u.email,
  u.articles_read,
  (SELECT COUNT(DISTINCT article_id) FROM read_history WHERE user_id = u.id) as actual_count
FROM users u
ORDER BY u.articles_read DESC;
