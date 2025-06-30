# Database Migration Instructions

## Menambahkan Kolom is_favorite ke Tabel habit

Untuk mengatasi error `Could not find the 'is_favorite' column`, Anda perlu menjalankan migration SQL di Supabase:

### Langkah-langkah:

1. **Buka Supabase Dashboard**

   - Login ke https://supabase.com
   - Pilih project Momentum Anda

2. **Buka SQL Editor**

   - Di sidebar kiri, klik "SQL Editor"
   - Klik "New query"

3. **Jalankan Migration SQL**
   - Copy dan paste isi file `supabase_migration_add_is_favorite.sql`
   - Atau copy script berikut:

```sql
-- SQL script to add is_favorite column to habit table
-- Run this in Supabase SQL Editor

-- Add is_favorite column to habit table
ALTER TABLE habit
ADD COLUMN IF NOT EXISTS is_favorite BOOLEAN DEFAULT FALSE;

-- Update existing records to have is_favorite = false if NULL
UPDATE habit
SET is_favorite = FALSE
WHERE is_favorite IS NULL;

-- Add comment to the column
COMMENT ON COLUMN habit.is_favorite IS 'Indicates whether the habit is marked as favorite by the user';

-- Create index for better performance when filtering favorite habits
CREATE INDEX IF NOT EXISTS idx_habit_is_favorite ON habit(is_favorite);
CREATE INDEX IF NOT EXISTS idx_habit_user_id_is_favorite ON habit(user_id, is_favorite);
```

4. **Execute Query**

   - Klik tombol "Run" untuk menjalankan migration
   - Pastikan tidak ada error

5. **Verifikasi**
   - Buka Table Editor
   - Pilih tabel `habit`
   - Pastikan kolom `is_favorite` sudah ada dengan tipe BOOLEAN

### Setelah Migration:

Setelah menjalankan migration SQL di atas, aplikasi akan dapat:

- Menyimpan status favorite habit ke database
- Mengupdate status favorite habit
- Menampilkan habit favorit di halaman Favorites

### Troubleshooting:

Jika masih ada error setelah migration:

1. Pastikan aplikasi terhubung ke database yang benar
2. Restart aplikasi Flutter
3. Clear cache dengan `flutter clean && flutter pub get`

### Structure Database Setelah Migration:

Tabel `habit` akan memiliki kolom:

- `id` (text, primary key)
- `user_id` (text, foreign key)
- `name` (text)
- `created_at` (timestamp)
- `focus_time_minutes` (integer)
- `start_time` (text, nullable)
- `priority` (text)
- `is_favorite` (boolean, default: false) ← **KOLOM BARU**
