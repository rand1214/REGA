-- Insert all 12 chapters for REGA Quiz App
-- Run this after creating the database schema
-- Only Chapter 1 is free, all others require subscription
-- Note: Run add_color_field_migration.sql after this to add colors

INSERT INTO public.chapters (
  chapter_number, 
  title_kurdish, 
  title_english, 
  is_free, 
  order_index, 
  description
) VALUES
-- Chapter 1 - FREE
(
  1, 
  'پێناسەکان', 
  'Definitions', 
  true, 
  1, 
  'ئەم بەشە باسی پێناسە گشتییەکان و زاراوەکانی هاتووچۆ دەکات'
),

-- Chapter 2 - SUBSCRIPTION REQUIRED
(
  2, 
  'بنەما گشتییەکان', 
  'General Principles', 
  false, 
  2, 
  'ئەم بەشە باسی بنەما گشتییەکانی لێخوڕین و یاساکانی سەر ڕێگا دەکات'
),

-- Chapter 3 - SUBSCRIPTION REQUIRED
(
  3, 
  'یاسای هاتووچۆ', 
  'Traffic Law', 
  false, 
  3, 
  'ئەم بەشە باسی یاساکانی هاتووچۆ و ڕێساکانی سەر ڕێگا دەکات'
),

-- Chapter 4 - SUBSCRIPTION REQUIRED
(
  4, 
  'هێما و کەرەستەکانی هاتووچۆ', 
  'Traffic Signs and Equipment', 
  false, 
  4, 
  'ئەم بەشە باسی هێماکانی هاتووچۆ و کەرەستەکانی ڕێگا دەکات'
),

-- Chapter 5 - SUBSCRIPTION REQUIRED
(
  5, 
  'بەشەکانی ئۆتۆمبێل', 
  'Car Parts', 
  false, 
  5, 
  'ئەم بەشە باسی بەشەکانی ئۆتۆمبێل و کارکردنیان دەکات'
),

-- Chapter 6 - SUBSCRIPTION REQUIRED
(
  6, 
  'خۆ ئامادەکردن بۆ لێخوڕین', 
  'Preparing to Drive', 
  false, 
  6, 
  'ئەم بەشە باسی خۆ ئامادەکردن بۆ لێخوڕین و پشکنینی ئۆتۆمبێل دەکات'
),

-- Chapter 7 - SUBSCRIPTION REQUIRED
(
  7, 
  'مانۆرکردن', 
  'Maneuvering', 
  false, 
  7, 
  'ئەم بەشە باسی مانۆرکردن و جوڵەکانی ئۆتۆمبێل دەکات'
),

-- Chapter 8 - SUBSCRIPTION REQUIRED
(
  8, 
  'بارودۆخی سەر ڕێگاکان', 
  'Road Conditions', 
  false, 
  8, 
  'ئەم بەشە باسی بارودۆخی جۆراوجۆری سەر ڕێگاکان دەکات'
),

-- Chapter 9 - SUBSCRIPTION REQUIRED
(
  9, 
  'هەلسەنگاندنی مەترسییەکان', 
  'Risk Assessment', 
  false, 
  9, 
  'ئەم بەشە باسی هەلسەنگاندنی مەترسییەکان و چۆنیەتی دوورکەوتنەوەیان دەکات'
),

-- Chapter 10 - SUBSCRIPTION REQUIRED
(
  10, 
  'تەندروستی شوفێر', 
  'Driver Health', 
  false, 
  10, 
  'ئەم بەشە باسی تەندروستی شوفێر، کاریگەری ماندووبوون و مادە هۆشبەر دەکات'
),

-- Chapter 11 - SUBSCRIPTION REQUIRED
(
  11, 
  'لێخوڕینی ژینگەپارێزان', 
  'Eco-Driving', 
  false, 
  11, 
  'ئەم بەشە باسی شێوازی لێخوڕینی ژینگەپارێز، کەمکردنەوەی سوتەمەنی و پاراستنی هەوا دەکات'
),

-- Chapter 12 - SUBSCRIPTION REQUIRED
(
  12, 
  'فریاگوزاری سەرەتایی', 
  'First Aid', 
  false, 
  12, 
  'ئەم بەشە باسی فریاگوزاری سەرەتایی، یارمەتیدانی بریندار و چارەسەری کاتی ڕووداو دەکات'
);

-- Verify the insert
SELECT chapter_number, title_kurdish, title_english, is_free 
FROM public.chapters 
ORDER BY order_index;

-- Next step: Run add_color_field_migration.sql to add colors
