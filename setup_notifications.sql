-- ============================================
-- SETUP NOTIFICATIONS TABLE FOR IDEN APP
-- ============================================
-- This script creates the notifications table and related policies
-- Run this in Supabase SQL Editor

-- 1. Create notifications table
CREATE TABLE IF NOT EXISTS notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    type TEXT NOT NULL CHECK (type IN ('article', 'quiz', 'system', 'admin')),
    is_read BOOLEAN DEFAULT FALSE,
    related_id TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. Create index for faster queries
CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_notifications_created_at ON notifications(created_at DESC);
CREATE INDEX idx_notifications_is_read ON notifications(is_read);

-- 3. Enable Row Level Security
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

-- 4. Create RLS Policies
-- Users can only see their own notifications
CREATE POLICY "Users can view their own notifications"
    ON notifications FOR SELECT
    USING (auth.uid() = user_id);

-- Users can update their own notifications (mark as read)
CREATE POLICY "Users can update their own notifications"
    ON notifications FOR UPDATE
    USING (auth.uid() = user_id);

-- Only admins can insert notifications (or use service role)
-- For now, allow authenticated users to insert (you can restrict later)
CREATE POLICY "Authenticated users can insert notifications"
    ON notifications FOR INSERT
    WITH CHECK (auth.role() = 'authenticated');

-- 5. Create function to auto-create notification when new article is added
CREATE OR REPLACE FUNCTION notify_users_on_new_article()
RETURNS TRIGGER AS $$
BEGIN
    -- Create notification for all users
    INSERT INTO notifications (user_id, title, message, type, related_id)
    SELECT 
        id,
        'Artikel Baru Tersedia',
        'Baca artikel terbaru: "' || NEW.title || '"',
        'article',
        NEW.id::TEXT
    FROM auth.users;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 6. Create trigger to run function on new article
DROP TRIGGER IF EXISTS on_article_created ON articles;
CREATE TRIGGER on_article_created
    AFTER INSERT ON articles
    FOR EACH ROW
    EXECUTE FUNCTION notify_users_on_new_article();

-- 7. Insert sample notifications for testing (optional)
-- Replace 'YOUR_USER_ID' with actual user ID from auth.users
/*
INSERT INTO notifications (user_id, title, message, type, is_read, created_at)
VALUES 
    ('YOUR_USER_ID', 'Selamat Datang di IDEN', 'Terima kasih telah mendaftar. Jelajahi fitur-fitur kami!', 'system', true, NOW() - INTERVAL '3 days'),
    ('YOUR_USER_ID', 'Artikel Baru Tersedia', 'Baca artikel terbaru tentang bahaya narkotika', 'article', false, NOW() - INTERVAL '2 hours'),
    ('YOUR_USER_ID', 'Saatnya Cek Risiko!', 'Yuk, isi kuis penilaian risiko untuk tahu tingkat keamananmu', 'quiz', false, NOW() - INTERVAL '1 day');
*/

-- 8. Verify setup
SELECT 'Notifications table created successfully!' AS status;
