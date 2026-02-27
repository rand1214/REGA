-- REGA Quiz App - Complete Supabase Database Schema
-- Run this in Supabase SQL Editor

-- ============================================
-- 1. PROFILES TABLE (extends auth.users)
-- ============================================
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

-- ============================================
-- 2. SUBSCRIPTIONS TABLE
-- ============================================
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

-- ============================================
-- 3. CHAPTERS TABLE
-- ============================================
CREATE TABLE public.chapters (
  id SERIAL PRIMARY KEY,
  chapter_number INTEGER UNIQUE NOT NULL,
  title_kurdish TEXT NOT NULL,
  title_english TEXT,
  description TEXT,
  color_hex TEXT NOT NULL, -- Hex color code for chapter
  is_free BOOLEAN DEFAULT false,
  order_index INTEGER NOT NULL,
  icon_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- 4. QUESTIONS TABLE
-- ============================================
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

-- ============================================
-- 5. USER PROGRESS TABLE
-- ============================================
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

-- ============================================
-- 6. QUIZ ATTEMPTS TABLE
-- ============================================
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

-- ============================================
-- 7. USER ANSWERS TABLE
-- ============================================
CREATE TABLE public.user_answers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  attempt_id UUID REFERENCES public.quiz_attempts(id) ON DELETE CASCADE,
  question_id UUID REFERENCES public.questions(id) ON DELETE CASCADE,
  user_answer TEXT NOT NULL CHECK (user_answer IN ('A', 'B', 'C')),
  is_correct BOOLEAN NOT NULL,
  time_taken_seconds INTEGER,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- 8. BOOKS TABLE
-- ============================================
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

-- ============================================
-- 9. PAYMENT TRANSACTIONS TABLE
-- ============================================
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

-- ============================================
-- 10. ADMIN USERS TABLE
-- ============================================
CREATE TABLE public.admin_users (
  id UUID REFERENCES auth.users(id) PRIMARY KEY,
  role TEXT DEFAULT 'admin' CHECK (role IN ('admin', 'super_admin')),
  permissions JSONB DEFAULT '[]'::jsonb,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- ENABLE ROW LEVEL SECURITY
-- ============================================
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

-- ============================================
-- RLS POLICIES - PROFILES
-- ============================================
CREATE POLICY "Users can view own profile"
  ON public.profiles FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Users can update own profile"
  ON public.profiles FOR UPDATE
  USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile"
  ON public.profiles FOR INSERT
  WITH CHECK (auth.uid() = id);

-- ============================================
-- RLS POLICIES - SUBSCRIPTIONS
-- ============================================
CREATE POLICY "Users can view own subscriptions"
  ON public.subscriptions FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Service role can manage subscriptions"
  ON public.subscriptions FOR ALL
  USING (auth.jwt()->>'role' = 'service_role');

-- ============================================
-- RLS POLICIES - CHAPTERS
-- ============================================
CREATE POLICY "Anyone can view chapters"
  ON public.chapters FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Only admins can modify chapters"
  ON public.chapters FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.admin_users
      WHERE id = auth.uid()
    )
  );

-- ============================================
-- RLS POLICIES - QUESTIONS
-- ============================================
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

CREATE POLICY "Only admins can modify questions"
  ON public.questions FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.admin_users
      WHERE id = auth.uid()
    )
  );

-- ============================================
-- RLS POLICIES - USER PROGRESS
-- ============================================
CREATE POLICY "Users can view own progress"
  ON public.user_progress FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can manage own progress"
  ON public.user_progress FOR ALL
  USING (auth.uid() = user_id);

-- ============================================
-- RLS POLICIES - QUIZ ATTEMPTS
-- ============================================
CREATE POLICY "Users can view own attempts"
  ON public.quiz_attempts FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own attempts"
  ON public.quiz_attempts FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- ============================================
-- RLS POLICIES - USER ANSWERS
-- ============================================
CREATE POLICY "Users can view own answers"
  ON public.user_answers FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.quiz_attempts qa
      WHERE qa.id = user_answers.attempt_id
      AND qa.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can insert own answers"
  ON public.user_answers FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.quiz_attempts qa
      WHERE qa.id = attempt_id
      AND qa.user_id = auth.uid()
    )
  );

-- ============================================
-- RLS POLICIES - BOOKS
-- ============================================
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

CREATE POLICY "Only admins can modify books"
  ON public.books FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.admin_users
      WHERE id = auth.uid()
    )
  );

-- ============================================
-- RLS POLICIES - PAYMENT TRANSACTIONS
-- ============================================
CREATE POLICY "Users can view own transactions"
  ON public.payment_transactions FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Service role can manage transactions"
  ON public.payment_transactions FOR ALL
  USING (auth.jwt()->>'role' = 'service_role');

-- ============================================
-- RLS POLICIES - ADMIN USERS
-- ============================================
CREATE POLICY "Super admins can view admin users"
  ON public.admin_users FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.admin_users
      WHERE id = auth.uid()
      AND role = 'super_admin'
    )
  );

-- ============================================
-- DATABASE FUNCTIONS
-- ============================================

-- Function to check subscription access
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

-- Function to update expired subscriptions
CREATE OR REPLACE FUNCTION public.update_expired_subscriptions()
RETURNS void AS $$
BEGIN
  UPDATE public.profiles
  SET subscription_status = 'expired'
  WHERE subscription_status = 'active'
  AND subscription_end_date < NOW();
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to create profile on signup
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

-- ============================================
-- INDEXES FOR PERFORMANCE
-- ============================================

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

-- ============================================
-- SAMPLE DATA (Optional - for testing)
-- ============================================

-- Insert all 12 chapters with real names and colors
INSERT INTO public.chapters (chapter_number, title_kurdish, title_english, color_hex, is_free, order_index, description) VALUES
(1, 'پێناسەکان', 'Definitions', '#B7D63E', true, 1, 'ئەم بەشە باسی پێناسە گشتییەکان و زاراوەکانی هاتووچۆ دەکات'),
(2, 'بنەما گشتییەکان', 'General Principles', '#F15A3C', false, 2, 'ئەم بەشە باسی بنەما گشتییەکانی لێخوڕین و یاساکانی سەر ڕێگا دەکات'),
(3, 'یاسای هاتووچۆ', 'Traffic Law', '#2FA7DF', false, 3, 'ئەم بەشە باسی یاساکانی هاتووچۆ و ڕێساکانی سەر ڕێگا دەکات'),
(4, 'هێما و کەرەستەکانی هاتووچۆ', 'Traffic Signs and Equipment', '#2F6EBB', false, 4, 'ئەم بەشە باسی هێماکانی هاتووچۆ و کەرەستەکانی ڕێگا دەکات'),
(5, 'بەشەکانی ئۆتۆمبێل', 'Car Parts', '#F4A640', false, 5, 'ئەم بەشە باسی بەشەکانی ئۆتۆمبێل و کارکردنیان دەکات'),
(6, 'خۆ ئامادەکردن بۆ لێخوڕین', 'Preparing to Drive', '#E91E63', false, 6, 'ئەم بەشە باسی خۆ ئامادەکردن بۆ لێخوڕین و پشکنینی ئۆتۆمبێل دەکات'),
(7, 'مانۆرکردن', 'Maneuvering', '#FF2C92', false, 7, 'ئەم بەشە باسی مانۆرکردن و جوڵەکانی ئۆتۆمبێل دەکات'),
(8, 'بارودۆخی سەر ڕێگاکان', 'Road Conditions', '#F3C21F', false, 8, 'ئەم بەشە باسی بارودۆخی جۆراوجۆری سەر ڕێگاکان دەکات'),
(9, 'هەلسەنگاندنی مەترسییەکان', 'Risk Assessment', '#7B3FA0', false, 9, 'ئەم بەشە باسی هەلسەنگاندنی مەترسییەکان و چۆنیەتی دوورکەوتنەوەیان دەکات'),
(10, 'تەندروستی شوفێر', 'Driver Health', '#20C6C2', false, 10, 'ئەم بەشە باسی تەندروستی شوفێر، کاریگەری ماندووبوون و مادە هۆشبەر دەکات'),
(11, 'لێخوڕینی ژینگەپارێزان', 'Eco-Driving', '#3FB34F', false, 11, 'ئەم بەشە باسی شێوازی لێخوڕینی ژینگەپارێز، کەمکردنەوەی سوتەمەنی و پاراستنی هەوا دەکات'),
(12, 'فریاگوزاری سەرەتایی', 'First Aid', '#E53935', false, 12, 'ئەم بەشە باسی فریاگوزاری سەرەتایی، یارمەتیدانی بریندار و چارەسەری کاتی ڕووداو دەکات');

-- Note: Add more sample data as needed for testing
