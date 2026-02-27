# REGA Chapters Documentation

## Overview
The REGA Quiz App contains 12 chapters covering all aspects of driving education in Kurdish (Sorani). Only Chapter 1 is free, while chapters 2-12 require an active subscription.

## Chapter List

### Chapter 1: پێناسەکان (Definitions) - FREE ✅
- **Color**: #B7D63E (Light Green)
- **Status**: Free for all users
- **Description**: Covers general definitions and traffic terminology
- **Topics**: Basic traffic terms, road user definitions, vehicle classifications

### Chapter 2: بنەما گشتییەکان (General Principles) - SUBSCRIPTION 🔒
- **Color**: #F15A3C (Orange Red)
- **Status**: Requires subscription
- **Description**: Covers general driving principles and road laws
- **Topics**: Basic driving rules, right of way, speed limits

### Chapter 3: یاسای هاتووچۆ (Traffic Law) - SUBSCRIPTION 🔒
- **Color**: #2FA7DF (Sky Blue)
- **Status**: Requires subscription
- **Description**: Covers traffic laws and road regulations
- **Topics**: Traffic regulations, legal requirements, penalties

### Chapter 4: هێما و کەرەستەکانی هاتووچۆ (Traffic Signs and Equipment) - SUBSCRIPTION 🔒
- **Color**: #2F6EBB (Royal Blue)
- **Status**: Requires subscription
- **Description**: Covers traffic signs and road equipment
- **Topics**: Warning signs, regulatory signs, informational signs, road markings

### Chapter 5: بەشەکانی ئۆتۆمبێل (Car Parts) - SUBSCRIPTION 🔒
- **Color**: #F4A640 (Orange)
- **Status**: Requires subscription
- **Description**: Covers car parts and their functions
- **Topics**: Engine components, safety features, control systems

### Chapter 6: خۆ ئامادەکردن بۆ لێخوڕین (Preparing to Drive) - SUBSCRIPTION 🔒
- **Color**: #E91E63 (Pink)
- **Status**: Requires subscription
- **Description**: Covers preparation for driving and vehicle inspection
- **Topics**: Pre-drive checks, seat adjustment, mirror positioning

### Chapter 7: مانۆرکردن (Maneuvering) - SUBSCRIPTION 🔒
- **Color**: #FF2C92 (Hot Pink)
- **Status**: Requires subscription
- **Description**: Covers vehicle maneuvering and movements
- **Topics**: Turning, parking, reversing, lane changing

### Chapter 8: بارودۆخی سەر ڕێگاکان (Road Conditions) - SUBSCRIPTION 🔒
- **Color**: #F3C21F (Yellow)
- **Status**: Requires subscription
- **Description**: Covers various road conditions
- **Topics**: Weather conditions, night driving, rural vs urban roads

### Chapter 9: هەلسەنگاندنی مەترسییەکان (Risk Assessment) - SUBSCRIPTION 🔒
- **Color**: #7B3FA0 (Purple)
- **Status**: Requires subscription
- **Description**: Covers risk assessment and hazard avoidance
- **Topics**: Identifying hazards, defensive driving, emergency situations

### Chapter 10: تەندروستی شوفێر (Driver Health) - SUBSCRIPTION 🔒
- **Color**: #20C6C2 (Turquoise)
- **Status**: Requires subscription
- **Description**: Covers driver health, fatigue effects, and substance influence
- **Topics**: Fatigue management, medication effects, alcohol and drugs

### Chapter 11: لێخوڕینی ژینگەپارێزان (Eco-Driving) - SUBSCRIPTION 🔒
- **Color**: #3FB34F (Green)
- **Status**: Requires subscription
- **Description**: Covers eco-friendly driving, fuel reduction, and air protection
- **Topics**: Fuel efficiency, emission reduction, environmental impact

### Chapter 12: فریاگوزاری سەرەتایی (First Aid) - SUBSCRIPTION 🔒
- **Color**: #E53935 (Red)
- **Status**: Requires subscription
- **Description**: Covers first aid, helping injured people, and emergency treatment
- **Topics**: Basic first aid, accident response, emergency procedures

## Database Structure

### Chapters Table Schema
```sql
CREATE TABLE public.chapters (
  id SERIAL PRIMARY KEY,
  chapter_number INTEGER UNIQUE NOT NULL,
  title_kurdish TEXT NOT NULL,
  title_english TEXT,
  description TEXT,
  color_hex TEXT NOT NULL,
  is_free BOOLEAN DEFAULT false,
  order_index INTEGER NOT NULL,
  icon_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

### Key Fields
- **chapter_number**: Unique identifier (1-12)
- **title_kurdish**: Kurdish (Sorani) title
- **title_english**: English translation
- **color_hex**: Hex color code for UI display
- **is_free**: Boolean flag (true only for Chapter 1)
- **order_index**: Display order
- **icon_url**: Optional icon image URL

## Access Control

### Free Access
- Chapter 1 is accessible to all users (logged in or not)
- Users can view and take quizzes for Chapter 1 without subscription

### Subscription Required
- Chapters 2-12 require an active subscription
- Subscription types:
  - Monthly: 30 days access
  - Yearly: 365 days access
- Access is checked via Row Level Security (RLS) policies

### RLS Policy
```sql
CREATE POLICY "Users can view accessible questions"
  ON public.questions FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.chapters c
      WHERE c.id = questions.chapter_id
      AND (
        c.is_free = true
        OR EXISTS (
          SELECT 1 FROM public.profiles p
          WHERE p.id = auth.uid()
          AND p.subscription_status = 'active'
        )
      )
    )
  );
```

## Flutter Integration

### ChapterModel Class
```dart
class ChapterModel {
  final int id;
  final int chapterNumber;
  final String titleKurdish;
  final String? titleEnglish;
  final String? description;
  final String colorHex;
  final bool isFree;
  final int orderIndex;
  
  Color get color {
    final hexColor = colorHex.replaceAll('#', '');
    return Color(int.parse('FF$hexColor', radix: 16));
  }
}
```

### ChapterService Methods
- `getAllChapters()` - Get all 12 chapters
- `getFreeChapters()` - Get only free chapters
- `getSubscriptionChapters()` - Get subscription-only chapters
- `canAccessChapter(chapterId)` - Check if user can access specific chapter
- `getAccessibleChapters()` - Get chapters user can access based on subscription

## Usage Examples

### Fetching Chapters
```dart
final chapterService = ChapterService();

// Get all chapters
final allChapters = await chapterService.getAllChapters();

// Get only accessible chapters for current user
final accessibleChapters = await chapterService.getAccessibleChapters();

// Check if user can access specific chapter
final canAccess = await chapterService.canAccessChapter(5);
```

### Displaying Chapters with Colors
```dart
ListView.builder(
  itemCount: chapters.length,
  itemBuilder: (context, index) {
    final chapter = chapters[index];
    return Container(
      color: chapter.color,
      child: ListTile(
        title: Text(chapter.titleKurdish),
        trailing: chapter.isFree 
          ? Icon(Icons.lock_open) 
          : Icon(Icons.lock),
      ),
    );
  },
);
```

## Installation Steps

1. **Create Supabase Project**
   - Go to https://supabase.com
   - Create new project

2. **Run Schema**
   ```bash
   # Run in Supabase SQL Editor
   supabase_schema.sql
   ```

3. **Insert Chapters**
   ```bash
   # Run in Supabase SQL Editor
   insert_chapters.sql
   ```

4. **Update Flutter .env**
   ```env
   SUPABASE_URL=your_project_url
   SUPABASE_ANON_KEY=your_anon_key
   ```

5. **Install Dependencies**
   ```bash
   flutter pub get
   ```

## Testing

### Verify Chapters in Database
```sql
SELECT chapter_number, title_kurdish, color_hex, is_free 
FROM public.chapters 
ORDER BY order_index;
```

### Test Access Control
```dart
// Test as non-subscribed user
final chapters = await chapterService.getAccessibleChapters();
// Should return only Chapter 1

// Test as subscribed user
// Should return all 12 chapters
```

## Future Enhancements

- Add chapter icons/images
- Track chapter completion percentage
- Add chapter prerequisites
- Implement chapter unlocking system
- Add chapter difficulty ratings
- Create chapter progress badges

## Notes

- All chapter titles are in Kurdish (Sorani script)
- Colors are carefully chosen for visual distinction
- Only Chapter 1 is free to encourage subscriptions
- RLS policies ensure secure access control
- Chapter data is cached for performance
