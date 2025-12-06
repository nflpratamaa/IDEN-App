# Database Migrations

Folder ini berisi SQL migration scripts untuk setup database Supabase.

## Migration Files

### 001_initial_schema.sql
Setup tabel users, articles, drugs, quiz, emergency contacts dengan RLS policies.

### 002_rls_policies.sql  
Update RLS policies untuk admin access dan public read.

### 003_seed_data.sql
Sample data untuk testing (articles, drugs, quiz questions).

### 004_read_history_bookmarks.sql ⭐ **NEW**
**Purpose**: Track artikel yang dibaca user dan bookmarks
**Tables Created**:
- `read_history`: History artikel yang dibaca user (with timestamp)
- `bookmarks`: Artikel yang di-bookmark user

**Functions**:
- `track_article_read(p_user_id, p_article_id)`: Auto track saat user baca artikel
- `toggle_bookmark(p_user_id, p_article_id)`: Toggle bookmark status

**Features**:
- Auto update `users.articles_read` count
- Auto update `users.saved_items` count
- Prevent duplicate entries dengan UNIQUE constraint
- RLS policies untuk security
- Indexes untuk performance

## How to Apply Migrations

### Option 1: Supabase Dashboard (Recommended)
1. Login ke [Supabase Dashboard](https://app.supabase.com)
2. Pilih project Anda
3. Go to **SQL Editor**
4. Buka file migration (copy paste content)
5. Click **Run** untuk execute

### Option 2: Supabase CLI
```bash
# Install Supabase CLI
npm install -g supabase

# Login
supabase login

# Link project
supabase link --project-ref your-project-ref

# Run migration
supabase db push
```

## Migration Order
Jalankan migrations sesuai urutan:
1. `001_initial_schema.sql`
2. `002_rls_policies.sql`
3. `003_seed_data.sql`
4. `004_read_history_bookmarks.sql` ⭐

## Testing Migrations

After running `004_read_history_bookmarks.sql`:

```sql
-- Test track_article_read function
SELECT track_article_read(
    'your-user-id'::UUID, 
    'article-id'::UUID
);

-- Verify read_history table
SELECT * FROM read_history WHERE user_id = 'your-user-id'::UUID;

-- Test toggle_bookmark function
SELECT toggle_bookmark(
    'your-user-id'::UUID, 
    'article-id'::UUID
);

-- Verify bookmarks table
SELECT * FROM bookmarks WHERE user_id = 'your-user-id'::UUID;

-- Check user stats
SELECT name, articles_read, saved_items 
FROM users 
WHERE id = 'your-user-id'::UUID;
```

## RLS Policies Summary

### read_history
- ✅ Users can view their own read history
- ✅ Users can insert their own read history
- ✅ Users can delete their own read history

### bookmarks
- ✅ Users can view their own bookmarks
- ✅ Users can insert their own bookmarks
- ✅ Users can delete their own bookmarks

## Notes
- Semua tables menggunakan UUID primary keys
- Timestamps menggunakan `TIMESTAMP WITH TIME ZONE`
- CASCADE delete untuk referential integrity
- UNIQUE constraints untuk prevent duplicates
- Indexes untuk query performance
- RLS enabled untuk security
- Functions dengan SECURITY DEFINER untuk auto-update stats
