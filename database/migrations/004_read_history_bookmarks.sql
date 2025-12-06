-- Migration: Read History & Bookmarks Tables
-- Created: 2025-12-05
-- Purpose: Track artikel yang dibaca user dan bookmarks

-- ============================================
-- Read History Table
-- ============================================
CREATE TABLE IF NOT EXISTS read_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    article_id UUID NOT NULL REFERENCES articles(id) ON DELETE CASCADE,
    read_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Prevent duplicate entries
    UNIQUE(user_id, article_id)
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_read_history_user_id ON read_history(user_id);
CREATE INDEX IF NOT EXISTS idx_read_history_article_id ON read_history(article_id);
CREATE INDEX IF NOT EXISTS idx_read_history_read_at ON read_history(read_at DESC);

-- Enable RLS
ALTER TABLE read_history ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Users can view their own read history"
    ON read_history FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own read history"
    ON read_history FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own read history"
    ON read_history FOR DELETE
    USING (auth.uid() = user_id);

-- ============================================
-- Bookmarks Table
-- ============================================
CREATE TABLE IF NOT EXISTS bookmarks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    article_id UUID NOT NULL REFERENCES articles(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Prevent duplicate bookmarks
    UNIQUE(user_id, article_id)
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_bookmarks_user_id ON bookmarks(user_id);
CREATE INDEX IF NOT EXISTS idx_bookmarks_article_id ON bookmarks(article_id);
CREATE INDEX IF NOT EXISTS idx_bookmarks_created_at ON bookmarks(created_at DESC);

-- Enable RLS
ALTER TABLE bookmarks ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Users can view their own bookmarks"
    ON bookmarks FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own bookmarks"
    ON bookmarks FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own bookmarks"
    ON bookmarks FOR DELETE
    USING (auth.uid() = user_id);

-- ============================================
-- Function: Auto-track read history
-- ============================================
-- This function can be called from app when user opens article
CREATE OR REPLACE FUNCTION track_article_read(
    p_user_id UUID,
    p_article_id UUID
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- Insert or update read timestamp
    INSERT INTO read_history (user_id, article_id, read_at)
    VALUES (p_user_id, p_article_id, NOW())
    ON CONFLICT (user_id, article_id) 
    DO UPDATE SET read_at = NOW();
    
    -- Update user statistics
    UPDATE users
    SET articles_read = articles_read + 1
    WHERE id = p_user_id
    AND NOT EXISTS (
        SELECT 1 FROM read_history 
        WHERE user_id = p_user_id 
        AND article_id = p_article_id 
        AND read_at < NOW() - INTERVAL '1 minute'
    );
END;
$$;

-- ============================================
-- Function: Toggle bookmark
-- ============================================
CREATE OR REPLACE FUNCTION toggle_bookmark(
    p_user_id UUID,
    p_article_id UUID
)
RETURNS BOOLEAN  -- Returns TRUE if bookmarked, FALSE if removed
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_exists BOOLEAN;
BEGIN
    -- Check if bookmark exists
    SELECT EXISTS(
        SELECT 1 FROM bookmarks 
        WHERE user_id = p_user_id 
        AND article_id = p_article_id
    ) INTO v_exists;
    
    IF v_exists THEN
        -- Remove bookmark
        DELETE FROM bookmarks 
        WHERE user_id = p_user_id 
        AND article_id = p_article_id;
        
        -- Update user statistics
        UPDATE users
        SET saved_items = GREATEST(saved_items - 1, 0)
        WHERE id = p_user_id;
        
        RETURN FALSE;
    ELSE
        -- Add bookmark
        INSERT INTO bookmarks (user_id, article_id)
        VALUES (p_user_id, p_article_id);
        
        -- Update user statistics
        UPDATE users
        SET saved_items = saved_items + 1
        WHERE id = p_user_id;
        
        RETURN TRUE;
    END IF;
END;
$$;

-- ============================================
-- Comments
-- ============================================
COMMENT ON TABLE read_history IS 'Tracks articles read by users';
COMMENT ON TABLE bookmarks IS 'User bookmarks for articles';
COMMENT ON FUNCTION track_article_read IS 'Automatically tracks when user reads an article';
COMMENT ON FUNCTION toggle_bookmark IS 'Toggles bookmark status and updates user stats';
