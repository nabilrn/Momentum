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
