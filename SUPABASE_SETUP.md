# Supabase Setup Guide for REGA Quiz App

## Overview
This guide covers the complete Supabase setup for REGA, including database schema, Row Level Security (RLS) policies, and subscription management.

## Step 1: Create Supabase Project

1. Go to [https://supabase.com](https://supabase.com)
2. Sign in or create an account
3. Click "New Project"
4. Fill in project details:
   - **Name**: REGA Quiz App
   - **Database Password**: (Generate a strong password and save it securely)
   - **Region**: Choose closest to your users
   - **Pricing Plan**: Start with Free tier, upgrade as needed

## Step 2: Database Schema

### Tables Structure

#### 1. users (extends Supabase auth.users)
```sql
CREATE TABLE public.profiles (
  id UUID REFERENCES auth.users(id) PRIMARY KEY,
  username TEXT UNIQUE,
  full_name TEXT,
  phone_number TEXT UNIQUE,
  avatar_url TEXT,
  subscription_status TEXT DEFAULT 'free' CHECK (subscription_status IN ('free', 'active', 'expired', 'cancelled')),
  subscription_tier TEXT CHECK (subscription_tier IN ('free', 'monthly', 'yearly')),
  subscription_start_date TIMESTAMPTZ,
  subscription_end_date TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

#### 2. subscriptions
```sql
CREATE TABLE public.subscriptions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  plan_type TEXT NOT NULL CHECK (plan_type IN ('monthly', 'yearly')),
  status TEXT DEFAULT 'active' CHECK (status IN ('active', 'cancelled', 'expired', 'pending')),
  start_date TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  end_date TIMESTAMPTZ NOT NULL,
  payment_method TEXT,
  amount DECIMAL(10,2) NOT NULL,
  currency TEXT DEFAULT 'USD',
  auto_renew BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

#### 3. chapters
```sql
CREATE TABLE public.chapters (
  id SERIAL PRIMARY KEY,
  chapter_number INTEGER UNIQUE NOT NULL,
  title_kurdish TEXT NOT NULL,
  title_english TEXT,
  description TEXT,
  is_free BOOLEAN DEFAULT false,
  order_index INTEGER NOT NULL,
  icon_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

#### 4. questions
```sql
CREATE TABLE public.questions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  chapter_id INTEGER REFERENCES public.chapters(id) ON DELETE CASCADE,
  question_text TEXT NOT NULL,
  question_image_url TEXT,
  option_a TEXT NOT NULL,
  option_b TEXT NOT NULL,
  option_c TEXT NOT NULL,
  correct_answer TEXT NOT NULL CHECK (correct_answer IN ('A', 'B', 'C')),
  explanation TEXT,
  difficulty TEXT CHECK (difficulty IN ('easy', 'medium', 'hard')),
  order_index INTEGER NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

#### 5. user_progress
```sql
CREATE TABLE public.user_progress (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  chapter_id INTEGER REFERENCES public.chapters(id) ON DELETE CASCADE,
  total_questions INTEGER DEFAULT 0,
  correct_answers INTEGER DEFAULT 0,
  incorrect_answers INTEGER DEFAULT 0,
  completion_percentage DECIMAL(5,2) DEFAULT 0,
  last_attempted_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, chapter_id)
);
```

#### 6. quiz_attempts
```sql
CREATE TABLE public.quiz_attempts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  chapter_id INTEGER REFERENCES public.chapters(id) ON DELETE CASCADE,
  score INTEGER NOT NULL,
  total_questions INTEGER NOT NULL,
  time_taken_seconds INTEGER,
  completed_at TIMESTAMPTZ DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

#### 7. user_answers
```sql
CREATE TABLE public.user_answers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  attempt_id UUID REFERENCES public.quiz_attempts(id) ON DELETE CASCADE,
  question_id UUID REFERENCES public.questions(id) ON DELETE CASCADE,
  user_answer TEXT NOT NULL CHECK (user_answer IN ('A', 'B', 'C')),
  is_correct BOOLEAN NOT NULL,
  time_taken_seconds INTEGER,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

#### 8. books
```sql
CREATE TABLE public.books (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  description TEXT,
  cover_image_url TEXT,
  pdf_url TEXT,
  is_free BOOLEAN DEFAULT false,
  order_index INTEGER NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

#### 9. payment_transactions
```sql
CREATE TABLE public.payment_transactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  subscription_id UUID REFERENCES public.subscriptions(id) ON DELETE SET NULL,
  amount DECIMAL(10,2) NOT NULL,
  currency TEXT DEFAULT 'USD',
  payment_method TEXT NOT NULL,
  payment_provider TEXT,
  transaction_id TEXT UNIQUE,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'completed', 'failed', 'refunded')),
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

#### 10. admin_users
```sql
CREATE TABLE public.admin_users (
  id UUID REFERENCES auth.users(id) PRIMARY KEY,
  role TEXT DEFAULT 'admin' CHECK (role IN ('admin', 'super_admin')),
  permissions JSONB DEFAULT '[]'::jsonb,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

## Step 3: Row Level Security (RLS) Policies

### Enable RLS on all tables
```sql
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chapters ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.quiz_attempts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_answers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.books ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payment_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.admin_users ENABLE ROW LEVEL SECURITY;
```

### Profiles Policies
```sql
-- Users can view their own profile
CREATE POLICY "Users can view own profile"
  ON public.profiles FOR SELECT
  USING (auth.uid() = id);

-- Users can update their own profile
CREATE POLICY "Users can update own profile"
  ON public.profiles FOR UPDATE
  USING (auth.uid() = id);

-- Users can insert their own profile
CREATE POLICY "Users can insert own profile"
  ON public.profiles FOR INSERT
  WITH CHECK (auth.uid() = id);
```

### Subscriptions Policies
```sql
-- Users can view their own subscriptions
CREATE POLICY "Users can view own subscriptions"
  ON public.subscriptions FOR SELECT
  USING (auth.uid() = user_id);

-- Only authenticated users can insert subscriptions (via backend)
CREATE POLICY "Service role can manage subscriptions"
  ON public.subscriptions FOR ALL
  USING (auth.jwt()->>'role' = 'service_role');
```

### Chapters Policies
```sql
-- Everyone can view chapters
CREATE POLICY "Anyone can view chapters"
  ON public.chapters FOR SELECT
  TO authenticated
  USING (true);

-- Only admins can modify chapters
CREATE POLICY "Only admins can modify chapters"
  ON public.chapters FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.admin_users
      WHERE id = auth.uid()
    )
  );
```

### Questions Policies
```sql
-- Users can view questions from chapters they have access to
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

-- Only admins can modify questions
CREATE POLICY "Only admins can modify questions"
  ON public.questions FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.admin_users
      WHERE id = auth.uid()
    )
  );
```

### User Progress Policies
```sql
-- Users can view their own progress
CREATE POLICY "Users can view own progress"
  ON public.user_progress FOR SELECT
  USING (auth.uid() = user_id);

-- Users can insert/update their own progress
CREATE POLICY "Users can manage own progress"
  ON public.user_progress FOR ALL
  USING (auth.uid() = user_id);
```

### Quiz Attempts Policies
```sql
-- Users can view their own attempts
CREATE POLICY "Users can view own attempts"
  ON public.quiz_attempts FOR SELECT
  USING (auth.uid() = user_id);

-- Users can insert their own attempts
CREATE POLICY "Users can insert own attempts"
  ON public.quiz_attempts FOR INSERT
  WITH CHECK (auth.uid() = user_id);
```

### User Answers Policies
```sql
-- Users can view their own answers
CREATE POLICY "Users can view own answers"
  ON public.user_answers FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.quiz_attempts qa
      WHERE qa.id = user_answers.attempt_id
      AND qa.user_id = auth.uid()
    )
  );

-- Users can insert their own answers
CREATE POLICY "Users can insert own answers"
  ON public.user_answers FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.quiz_attempts qa
      WHERE qa.id = attempt_id
      AND qa.user_id = auth.uid()
    )
  );
```

### Books Policies
```sql
-- Users can view books they have access to
CREATE POLICY "Users can view accessible books"
  ON public.books FOR SELECT
  TO authenticated
  USING (
    is_free = true
    OR EXISTS (
      SELECT 1 FROM public.profiles p
      WHERE p.id = auth.uid()
      AND p.subscription_status = 'active'
    )
  );

-- Only admins can modify books
CREATE POLICY "Only admins can modify books"
  ON public.books FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.admin_users
      WHERE id = auth.uid()
    )
  );
```

### Payment Transactions Policies
```sql
-- Users can view their own transactions
CREATE POLICY "Users can view own transactions"
  ON public.payment_transactions FOR SELECT
  USING (auth.uid() = user_id);

-- Service role can manage transactions
CREATE POLICY "Service role can manage transactions"
  ON public.payment_transactions FOR ALL
  USING (auth.jwt()->>'role' = 'service_role');
```

### Admin Users Policies
```sql
-- Only super admins can view admin users
CREATE POLICY "Super admins can view admin users"
  ON public.admin_users FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.admin_users
      WHERE id = auth.uid()
      AND role = 'super_admin'
    )
  );
```

## Step 4: Database Functions

### Function to check subscription access
```sql
CREATE OR REPLACE FUNCTION public.has_active_subscription(user_uuid UUID)
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM public.profiles
    WHERE id = user_uuid
    AND subscription_status = 'active'
    AND subscription_end_date > NOW()
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

### Function to update subscription status
```sql
CREATE OR REPLACE FUNCTION public.update_expired_subscriptions()
RETURNS void AS $$
BEGIN
  UPDATE public.profiles
  SET subscription_status = 'expired'
  WHERE subscription_status = 'active'
  AND subscription_end_date < NOW();
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

### Function to create profile on signup
```sql
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, username, full_name)
  VALUES (
    NEW.id,
    NEW.raw_user_meta_data->>'username',
    NEW.raw_user_meta_data->>'full_name'
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to automatically create profile
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
```

## Step 5: Indexes for Performance

```sql
-- Profiles indexes
CREATE INDEX idx_profiles_subscription_status ON public.profiles(subscription_status);
CREATE INDEX idx_profiles_phone_number ON public.profiles(phone_number);

-- Subscriptions indexes
CREATE INDEX idx_subscriptions_user_id ON public.subscriptions(user_id);
CREATE INDEX idx_subscriptions_status ON public.subscriptions(status);
CREATE INDEX idx_subscriptions_end_date ON public.subscriptions(end_date);

-- Questions indexes
CREATE INDEX idx_questions_chapter_id ON public.questions(chapter_id);
CREATE INDEX idx_questions_order_index ON public.questions(order_index);

-- User progress indexes
CREATE INDEX idx_user_progress_user_id ON public.user_progress(user_id);
CREATE INDEX idx_user_progress_chapter_id ON public.user_progress(chapter_id);

-- Quiz attempts indexes
CREATE INDEX idx_quiz_attempts_user_id ON public.quiz_attempts(user_id);
CREATE INDEX idx_quiz_attempts_chapter_id ON public.quiz_attempts(chapter_id);
CREATE INDEX idx_quiz_attempts_completed_at ON public.quiz_attempts(completed_at);

-- User answers indexes
CREATE INDEX idx_user_answers_attempt_id ON public.user_answers(attempt_id);
CREATE INDEX idx_user_answers_question_id ON public.user_answers(question_id);

-- Payment transactions indexes
CREATE INDEX idx_payment_transactions_user_id ON public.payment_transactions(user_id);
CREATE INDEX idx_payment_transactions_status ON public.payment_transactions(status);
```

## Step 6: Storage Buckets

Create storage buckets for media files:

1. **avatars** - User profile pictures
   - Public: false
   - File size limit: 2MB
   - Allowed MIME types: image/jpeg, image/png, image/webp

2. **question-images** - Question images
   - Public: true
   - File size limit: 5MB
   - Allowed MIME types: image/jpeg, image/png, image/webp

3. **book-covers** - Book cover images
   - Public: true
   - File size limit: 2MB
   - Allowed MIME types: image/jpeg, image/png, image/webp

4. **book-pdfs** - Book PDF files
   - Public: false
   - File size limit: 50MB
   - Allowed MIME types: application/pdf

### Storage Policies

```sql
-- Avatars bucket policies
CREATE POLICY "Users can upload own avatar"
  ON storage.objects FOR INSERT
  TO authenticated
  WITH CHECK (
    bucket_id = 'avatars'
    AND auth.uid()::text = (storage.foldername(name))[1]
  );

CREATE POLICY "Users can update own avatar"
  ON storage.objects FOR UPDATE
  TO authenticated
  USING (
    bucket_id = 'avatars'
    AND auth.uid()::text = (storage.foldername(name))[1]
  );

CREATE POLICY "Users can view own avatar"
  ON storage.objects FOR SELECT
  TO authenticated
  USING (
    bucket_id = 'avatars'
    AND auth.uid()::text = (storage.foldername(name))[1]
  );

-- Question images - public read, admin write
CREATE POLICY "Anyone can view question images"
  ON storage.objects FOR SELECT
  TO authenticated
  USING (bucket_id = 'question-images');

CREATE POLICY "Admins can upload question images"
  ON storage.objects FOR INSERT
  TO authenticated
  WITH CHECK (
    bucket_id = 'question-images'
    AND EXISTS (
      SELECT 1 FROM public.admin_users
      WHERE id = auth.uid()
    )
  );
```

## Step 7: Environment Variables

Add these to your Flutter app's `.env` file:

```env
SUPABASE_URL=your_project_url
SUPABASE_ANON_KEY=your_anon_key
SUPABASE_SERVICE_ROLE_KEY=your_service_role_key
```

## Security Best Practices

1. **Never expose service_role_key in client apps**
2. **Always use RLS policies** - Never disable RLS
3. **Validate all inputs** on both client and server
4. **Use prepared statements** to prevent SQL injection
5. **Implement rate limiting** for API calls
6. **Enable email verification** for new users
7. **Use HTTPS only** for all connections
8. **Regularly backup database**
9. **Monitor suspicious activities**
10. **Keep Supabase client library updated**

## Next Steps

1. Run all SQL commands in Supabase SQL Editor
2. Create storage buckets via Supabase Dashboard
3. Add Flutter Supabase package
4. Implement authentication flow
5. Test RLS policies thoroughly
6. Set up payment integration
7. Create admin dashboard

## Testing RLS Policies

Use Supabase SQL Editor with different user contexts:

```sql
-- Test as specific user
SET request.jwt.claim.sub = 'user-uuid-here';

-- Test queries
SELECT * FROM public.questions;
SELECT * FROM public.user_progress;
```

## Monitoring and Maintenance

1. Set up Supabase alerts for:
   - Failed authentication attempts
   - High database load
   - Storage quota warnings
   
2. Schedule regular tasks:
   - Run `update_expired_subscriptions()` daily
   - Clean up old quiz attempts (optional)
   - Backup database weekly

3. Monitor metrics:
   - Active users
   - Subscription conversion rate
   - Quiz completion rates
   - API response times
