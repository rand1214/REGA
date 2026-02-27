-- Migration: Add color_hex field to chapters table
-- Run this AFTER the initial schema has been created
-- This adds the color field and updates all 12 chapters with their colors

-- Step 1: Add color_hex column to chapters table
ALTER TABLE public.chapters 
ADD COLUMN IF NOT EXISTS color_hex TEXT;

-- Step 2: Update existing chapters with their colors
-- If chapters don't exist, this will do nothing (safe to run)

UPDATE public.chapters SET color_hex = '#B7D63E' WHERE chapter_number = 1;
UPDATE public.chapters SET color_hex = '#F15A3C' WHERE chapter_number = 2;
UPDATE public.chapters SET color_hex = '#2FA7DF' WHERE chapter_number = 3;
UPDATE public.chapters SET color_hex = '#2F6EBB' WHERE chapter_number = 4;
UPDATE public.chapters SET color_hex = '#F4A640' WHERE chapter_number = 5;
UPDATE public.chapters SET color_hex = '#E91E63' WHERE chapter_number = 6;
UPDATE public.chapters SET color_hex = '#FF2C92' WHERE chapter_number = 7;
UPDATE public.chapters SET color_hex = '#F3C21F' WHERE chapter_number = 8;
UPDATE public.chapters SET color_hex = '#7B3FA0' WHERE chapter_number = 9;
UPDATE public.chapters SET color_hex = '#20C6C2' WHERE chapter_number = 10;
UPDATE public.chapters SET color_hex = '#3FB34F' WHERE chapter_number = 11;
UPDATE public.chapters SET color_hex = '#E53935' WHERE chapter_number = 12;

-- Step 3: Make color_hex NOT NULL after updating existing data
ALTER TABLE public.chapters 
ALTER COLUMN color_hex SET NOT NULL;

-- Step 4: Verify the migration
SELECT chapter_number, title_kurdish, color_hex, is_free 
FROM public.chapters 
ORDER BY order_index;
