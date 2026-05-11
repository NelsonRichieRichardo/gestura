-- SQL Script to setup Supabase for Gestura App

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Drop existing tables to ensure a clean slate
DROP TABLE IF EXISTS public.user_level_progress CASCADE;
DROP TABLE IF EXISTS public.exercise_levels CASCADE;
DROP TABLE IF EXISTS public.exercise_units CASCADE;
DROP TABLE IF EXISTS public.history_items CASCADE;
DROP TABLE IF EXISTS public.dictionary_items CASCADE;
DROP TABLE IF EXISTS public.users CASCADE;

-- 1. Create Dictionary Table
CREATE TABLE public.dictionary_items (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    category TEXT NOT NULL, -- 'Huruf', 'Kata', 'Kalimat'
    sign TEXT NOT NULL,
    description TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Insert data into dictionary_items
-- Kategori: Huruf
INSERT INTO public.dictionary_items (category, sign, description) VALUES
('Huruf', 'A', 'Isyarat tangan untuk huruf A'),
('Huruf', 'B', 'Isyarat tangan untuk huruf B'),
('Huruf', 'C', 'Isyarat tangan untuk huruf C'),
('Huruf', 'D', 'Isyarat tangan untuk huruf D'),
('Huruf', 'E', 'Isyarat tangan untuk huruf E'),
('Huruf', 'F', 'Isyarat tangan untuk huruf F'),
('Huruf', 'G', 'Isyarat tangan untuk huruf G'),
('Huruf', 'H', 'Isyarat tangan untuk huruf H'),
('Huruf', 'I', 'Isyarat tangan untuk huruf I'),
('Huruf', 'J', 'Isyarat tangan untuk huruf J'),
('Huruf', 'K', 'Isyarat tangan untuk huruf K'),
('Huruf', 'L', 'Isyarat tangan untuk huruf L'),
('Huruf', 'M', 'Isyarat tangan untuk huruf M'),
('Huruf', 'N', 'Isyarat tangan untuk huruf N'),
('Huruf', 'O', 'Isyarat tangan untuk huruf O'),
('Huruf', 'P', 'Isyarat tangan untuk huruf P'),
('Huruf', 'Q', 'Isyarat tangan untuk huruf Q'),
('Huruf', 'R', 'Isyarat tangan untuk huruf R'),
('Huruf', 'S', 'Isyarat tangan untuk huruf S'),
('Huruf', 'T', 'Isyarat tangan untuk huruf T'),
('Huruf', 'U', 'Isyarat tangan untuk huruf U'),
('Huruf', 'V', 'Isyarat tangan untuk huruf V'),
('Huruf', 'W', 'Isyarat tangan untuk huruf W'),
('Huruf', 'X', 'Isyarat tangan untuk huruf X'),
('Huruf', 'Y', 'Isyarat tangan untuk huruf Y'),
('Huruf', 'Z', 'Isyarat tangan untuk huruf Z');

-- Kategori: Kata
INSERT INTO public.dictionary_items (category, sign, description) VALUES
('Kata', 'Halo', 'Sapaan umum untuk menyapa seseorang'),
('Kata', 'Teman', 'Seseorang yang dikenal dan dipercaya'),
('Kata', 'Saya', 'Menunjuk pada diri sendiri'),
('Kata', 'Makan', 'Kegiatan memasukkan makanan ke mulut'),
('Kata', 'Minum', 'Kegiatan memasukkan minuman ke mulut'),
('Kata', 'Keluarga', 'Sekumpulan orang yang terikat darah/perkawinan'),
('Kata', 'Ibu', 'Orang tua perempuan'),
('Kata', 'Ayah', 'Orang tua laki-laki');

-- Kategori: Kalimat
INSERT INTO public.dictionary_items (category, sign, description) VALUES
('Kalimat', 'Aku Cinta Kamu', 'Ungkapan kasih sayang (I Love You) 🤟'),
('Kalimat', 'Apa Kabar?', 'Bertanya tentang kondisi seseorang'),
('Kalimat', 'Sampai Jumpa', 'Salam perpisahan');


-- 2. Create Exercise Units Table
CREATE TABLE public.exercise_units (
    id SERIAL PRIMARY KEY,
    unit_title TEXT NOT NULL,
    unit_desc TEXT NOT NULL,
    color_hex TEXT NOT NULL, -- e.g., '0xFF2196F3' for Colors.blue
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Insert Exercise Units
INSERT INTO public.exercise_units (id, unit_title, unit_desc, color_hex) VALUES
(1, 'Unit 1: The Basics', 'Core Alphabet & Numbers 1-10', '0xFF2196F3'), -- Blue
(2, 'Unit 2: Introductions', 'Greetings and Basic Phrases', '0xFF4CAF50'), -- Green
(3, 'Unit 3: Daily Life', 'Food, Drink, and Common Verbs', '0xFFFF9800'), -- Orange
(4, 'Unit 4: Family & Home', 'Relationships, Places, and Pronouns', '0xFF3F51B5'), -- Indigo
(5, 'Unit 5: Time & Date', 'Days, Months, and Seasons', '0xFF9C27B0'), -- Purple
(6, 'Unit 6: Feelings & Health', 'Emotions, Descriptions, and Illness', '0xFFE91E63'), -- Pink
(7, 'Unit 7: Travel & Transport', 'Directions, Locations, and Vehicles', '0xFF795548'), -- Brown
(8, 'Unit 8: Education & Work', 'School Subjects and Occupations', '0xFF00BCD4'), -- Cyan
(9, 'Unit 9: Hobbies & Leisure', 'Sports, Music, and Free Time Activities', '0xFF9E9D24'), -- Lime[800]
(10, 'Unit 10: Abstract Concepts', 'Ideas, Opinions, and Complex Terms', '0xFFF44336'); -- Red


-- 3. Create Exercise Levels Table
CREATE TABLE public.exercise_levels (
    id SERIAL PRIMARY KEY,
    unit_id INTEGER REFERENCES public.exercise_units(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    icon_name TEXT NOT NULL, -- Name of the MaterialIcon
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Insert Exercise Levels
-- Unit 1
INSERT INTO public.exercise_levels (id, unit_id, title, icon_name) VALUES
(1, 1, 'Core Alphabet', 'back_hand'),
(2, 1, 'Numbers 1-10', 'translate'),
(3, 1, 'Simple Words', 'question_answer'),
(4, 1, 'Unit Quiz', 'quiz');

-- Unit 2
INSERT INTO public.exercise_levels (id, unit_id, title, icon_name) VALUES
(5, 2, 'Greetings', 'people'),
(6, 2, 'Self Introduction', 'emoji_people'),
(7, 2, 'Practice Sentences', 'record_voice_over');

-- Unit 3
INSERT INTO public.exercise_levels (id, unit_id, title, icon_name) VALUES
(8, 3, 'Food & Drink', 'restaurant'),
(9, 3, 'Time & Schedule', 'schedule'),
(10, 3, 'Common Verbs', 'directions_run'),
(11, 3, 'Unit Quiz', 'quiz');

-- Unit 4
INSERT INTO public.exercise_levels (id, unit_id, title, icon_name) VALUES
(12, 4, 'Family Members', 'group'),
(13, 4, 'Rooms & Objects', 'home'),
(14, 4, 'Possessives', 'bookmark_added');

-- Unit 5
INSERT INTO public.exercise_levels (id, unit_id, title, icon_name) VALUES
(15, 5, 'Days of Week', 'calendar_today'),
(16, 5, 'Months & Year', 'calendar_month'),
(17, 5, 'Seasons & Weather', 'cloud'),
(18, 5, 'Unit Quiz', 'quiz');

-- Unit 6
INSERT INTO public.exercise_levels (id, unit_id, title, icon_name) VALUES
(19, 6, 'Basic Emotions', 'sentiment_satisfied'),
(20, 6, 'Describing People', 'face');

-- Unit 7
INSERT INTO public.exercise_levels (id, unit_id, title, icon_name) VALUES
(21, 7, 'Directions', 'directions'),
(22, 7, 'Transportation Types', 'directions_bus'),
(23, 7, 'Asking for Location', 'location_on');

-- Unit 8
INSERT INTO public.exercise_levels (id, unit_id, title, icon_name) VALUES
(24, 8, 'School Subjects', 'book'),
(25, 8, 'Professions', 'business_center'),
(26, 8, 'Unit Quiz', 'quiz');

-- Unit 9
INSERT INTO public.exercise_levels (id, unit_id, title, icon_name) VALUES
(27, 9, 'Sports', 'sports_soccer'),
(28, 9, 'Music & Arts', 'music_note'),
(29, 9, 'Free Time Activities', 'videogame_asset');

-- Unit 10
INSERT INTO public.exercise_levels (id, unit_id, title, icon_name) VALUES
(30, 10, 'Opinions', 'lightbulb'),
(31, 10, 'Abstract Ideas', 'psychology'),
(32, 10, 'Final Review', 'flag_rounded'),
(33, 10, 'Final Exam', 'quiz');


-- 4. Create User Level Progress Table (For saving progress per user)
CREATE TABLE public.user_level_progress (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id TEXT NOT NULL, -- Supabase Auth UID
    level_id INTEGER REFERENCES public.exercise_levels(id) ON DELETE CASCADE,
    status TEXT DEFAULT 'locked', -- 'locked', 'current', 'completed'
    stars INTEGER DEFAULT 0,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, level_id)
);

-- Enable RLS (Row Level Security) and add policies if you use Supabase Auth
-- For now, to ensure app works immediately we can disable RLS or add public policy
ALTER TABLE public.dictionary_items ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Enable read access for all users" ON public.dictionary_items FOR SELECT USING (true);

ALTER TABLE public.exercise_units ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Enable read access for all users" ON public.exercise_units FOR SELECT USING (true);

ALTER TABLE public.exercise_levels ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Enable read access for all users" ON public.exercise_levels FOR SELECT USING (true);

ALTER TABLE public.user_level_progress ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Enable all access for all users for testing" ON public.user_level_progress FOR ALL USING (true) WITH CHECK (true);

-- 5. Create History Items Table
CREATE TABLE public.history_items (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id TEXT NOT NULL, -- Supabase Auth UID
    title TEXT NOT NULL,
    subtitle TEXT NOT NULL,
    time_label TEXT NOT NULL,
    icon_name TEXT NOT NULL,
    color_hex TEXT NOT NULL,
    item_type TEXT NOT NULL, -- 'translation', 'learning', 'quiz'
    detail_payload TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Removed Dummy History (Now app is 100% real data based on user activity)

ALTER TABLE public.history_items ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Enable all access for all users for testing" ON public.history_items FOR ALL USING (true) WITH CHECK (true);

-- 6. Create Users Table for Profile
CREATE TABLE public.users (
    id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
    username TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Enable read access for all users" ON public.users FOR SELECT USING (true);
CREATE POLICY "Enable insert for authenticated users" ON public.users FOR INSERT WITH CHECK (auth.uid() = id);
CREATE POLICY "Enable update for users based on id" ON public.users FOR UPDATE USING (auth.uid() = id);

-- Trigger to auto insert public.users when a new auth.users is created
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.users (id, username)
  VALUES (new.id, COALESCE(new.raw_user_meta_data->>'username', split_part(new.email, '@', 1)));
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

-- Dummy account creation is best done via the App's Register page 
-- or via the Supabase Dashboard (Authentication -> Add User) 
-- to ensure GoTrue identity schemas are properly generated without errors.

-- 8. GRANT PERMISSIONS TO ROLES
-- This prevents the "permission denied for table" (42501) error
GRANT SELECT, INSERT, UPDATE, DELETE ON public.dictionary_items TO anon, authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.exercise_units TO anon, authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.exercise_levels TO anon, authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.user_level_progress TO anon, authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.history_items TO anon, authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.users TO anon, authenticated;
