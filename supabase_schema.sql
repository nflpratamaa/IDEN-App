-- ================================
-- IDEN App - Supabase Database Schema
-- ================================

-- 1. USERS TABLE (Extended dari auth.users)
CREATE TABLE users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  email TEXT NOT NULL UNIQUE,
  quizzes_taken INTEGER DEFAULT 0,
  articles_read INTEGER DEFAULT 0,
  saved_items INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. DRUGS TABLE (Katalog Narkotika)
CREATE TABLE drugs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  other_names TEXT DEFAULT '', -- Nama lain/alias (contoh: "Sabu, Ice, Crystal Meth")
  category TEXT NOT NULL,
  description TEXT NOT NULL,
  effects TEXT[] NOT NULL DEFAULT '{}',
  dangers TEXT[] NOT NULL DEFAULT '{}',
  legal_status TEXT NOT NULL,
  image_url TEXT,
  risk_level TEXT NOT NULL CHECK (risk_level IN ('low', 'medium', 'high', 'extreme')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. ARTICLES TABLE (Artikel Edukasi)
CREATE TABLE articles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  image_url TEXT,
  author TEXT NOT NULL,
  category TEXT NOT NULL,
  read_time INTEGER DEFAULT 5,
  read_count INTEGER DEFAULT 0,
  published_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  tags TEXT[] NOT NULL DEFAULT '{}',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4. QUIZZES TABLE (Quiz Questions)
CREATE TABLE quizzes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  question TEXT NOT NULL,
  type TEXT NOT NULL CHECK (type IN ('multiple_choice', 'yes_no', 'scale')),
  options TEXT[] NOT NULL DEFAULT '{}',
  weight INTEGER DEFAULT 1 CHECK (weight >= 0 AND weight <= 10),
  category TEXT NOT NULL,
  order_index INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 5. QUIZ_RESULTS TABLE (Hasil Quiz User)
CREATE TABLE quiz_results (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  total_score INTEGER NOT NULL CHECK (total_score >= 0 AND total_score <= 100),
  risk_level TEXT NOT NULL CHECK (risk_level IN ('low', 'medium', 'high', 'extreme')),
  answers JSONB NOT NULL DEFAULT '{}',
  recommendations TEXT[] NOT NULL DEFAULT '{}',
  completed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 6. EMERGENCY_CONTACTS TABLE (Kontak Darurat)
CREATE TABLE emergency_contacts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  type TEXT NOT NULL CHECK (type IN ('hotline', 'rehab', 'counseling', 'support_group')),
  phone TEXT,
  email TEXT,
  address TEXT,
  description TEXT,
  is_available_24_7 BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ================================
-- INDEXES untuk performa query
-- ================================

CREATE INDEX idx_drugs_category ON drugs(category);
CREATE INDEX idx_drugs_risk_level ON drugs(risk_level);
CREATE INDEX idx_articles_category ON articles(category);
CREATE INDEX idx_articles_published_at ON articles(published_at DESC);
CREATE INDEX idx_quiz_results_user_id ON quiz_results(user_id);
CREATE INDEX idx_quiz_results_completed_at ON quiz_results(completed_at DESC);
CREATE INDEX idx_quizzes_order_index ON quizzes(order_index);

-- ================================
-- ROW LEVEL SECURITY (RLS)
-- ================================

-- Enable RLS
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE drugs ENABLE ROW LEVEL SECURITY;
ALTER TABLE articles ENABLE ROW LEVEL SECURITY;
ALTER TABLE quizzes ENABLE ROW LEVEL SECURITY;
ALTER TABLE quiz_results ENABLE ROW LEVEL SECURITY;
ALTER TABLE emergency_contacts ENABLE ROW LEVEL SECURITY;

-- Users policies
CREATE POLICY "Users can view their own data" ON users
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update their own data" ON users
  FOR UPDATE USING (auth.uid() = id);

-- Drugs policies (Public read, Admin write)
CREATE POLICY "Anyone can view drugs" ON drugs
  FOR SELECT USING (true);

CREATE POLICY "Only authenticated users can insert drugs" ON drugs
  FOR INSERT WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Only authenticated users can update drugs" ON drugs
  FOR UPDATE USING (auth.role() = 'authenticated');

CREATE POLICY "Only authenticated users can delete drugs" ON drugs
  FOR DELETE USING (auth.role() = 'authenticated');

-- Articles policies (Public read, Admin write)
CREATE POLICY "Anyone can view articles" ON articles
  FOR SELECT USING (true);

CREATE POLICY "Only authenticated users can insert articles" ON articles
  FOR INSERT WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Only authenticated users can update articles" ON articles
  FOR UPDATE USING (auth.role() = 'authenticated');

CREATE POLICY "Only authenticated users can delete articles" ON articles
  FOR DELETE USING (auth.role() = 'authenticated');

-- Quizzes policies (Public read, Admin write)
CREATE POLICY "Anyone can view quizzes" ON quizzes
  FOR SELECT USING (true);

CREATE POLICY "Only authenticated users can insert quizzes" ON quizzes
  FOR INSERT WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Only authenticated users can update quizzes" ON quizzes
  FOR UPDATE USING (auth.role() = 'authenticated');

CREATE POLICY "Only authenticated users can delete quizzes" ON quizzes
  FOR DELETE USING (auth.role() = 'authenticated');

-- Quiz Results policies (Users can only see their own)
CREATE POLICY "Users can view their own quiz results" ON quiz_results
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own quiz results" ON quiz_results
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Emergency Contacts policies (Public read, Admin write)
CREATE POLICY "Anyone can view emergency contacts" ON emergency_contacts
  FOR SELECT USING (true);

CREATE POLICY "Only authenticated users can manage emergency contacts" ON emergency_contacts
  FOR ALL USING (auth.role() = 'authenticated');

-- ================================
-- FUNCTIONS & TRIGGERS
-- ================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers for updated_at
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_drugs_updated_at BEFORE UPDATE ON drugs
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_articles_updated_at BEFORE UPDATE ON articles
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_quizzes_updated_at BEFORE UPDATE ON quizzes
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_emergency_contacts_updated_at BEFORE UPDATE ON emergency_contacts
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ================================
-- SAMPLE DATA (untuk testing)
-- ================================

-- Sample Drugs
INSERT INTO drugs (name, other_names, category, description, effects, dangers, legal_status, risk_level) VALUES
('Ganja/Marihuana', 'Cannabis, Weed, Marijuana, Cimeng', 'Golongan I', 'Tanaman Cannabis sativa yang mengandung THC', 
  ARRAY['Relaksasi', 'Euphoria', 'Gangguan memori', 'Persepsi terganggu'], 
  ARRAY['Kecanduan psikologis', 'Gangguan paru-paru', 'Penurunan motivasi', 'Gangguan mental'],
  'Ilegal - Golongan I UU Narkotika', 'high'),

('Sabu-sabu/Metamfetamin', 'Sabu, Ice, Crystal Meth, Shabu', 'Golongan I', 'Stimulan kuat yang sangat adiktif',
  ARRAY['Energi meningkat', 'Kurang tidur', 'Nafsu makan hilang', 'Euphoria'],
  ARRAY['Kecanduan tinggi', 'Kerusakan otak', 'Psikosis', 'Gangguan jantung', 'Kematian'],
  'Ilegal - Golongan I UU Narkotika', 'extreme'),

('Ekstasi/MDMA', 'Ecstasy, Molly, Inex', 'Golongan I', 'Stimulan dan halusinogen sintetis',
  ARRAY['Euphoria', 'Empati meningkat', 'Energi tinggi', 'Halusinasi ringan'],
  ARRAY['Dehidrasi', 'Overheating', 'Kerusakan otak', 'Depresi', 'Gangguan memori'],
  'Ilegal - Golongan I UU Narkotika', 'high');

-- Sample Articles
INSERT INTO articles (title, content, author, category, read_time, tags) VALUES
('Bahaya Narkotika bagi Generasi Muda', 
  'Narkotika merupakan ancaman serius bagi generasi muda Indonesia. Artikel ini membahas dampak jangka panjang penggunaan narkoba...',
  'Dr. Ahmad Susanto', 'Edukasi', 8, ARRAY['narkotika', 'generasi-muda', 'bahaya']),

('Cara Menolak Tawaran Narkoba', 
  'Tips praktis untuk menolak tawaran narkoba dari teman atau lingkungan sekitar dengan cara yang asertif...',
  'Psikolog Sarah Wijaya', 'Tips', 5, ARRAY['pencegahan', 'tips', 'remaja']),

('Proses Rehabilitasi Pengguna Narkoba',
  'Memahami tahapan rehabilitasi dari detoksifikasi hingga reintegrasi sosial...',
  'Dr. Budi Santoso', 'Rehabilitasi', 10, ARRAY['rehabilitasi', 'pemulihan', 'treatment']);

-- Sample Quiz Questions
INSERT INTO quizzes (question, type, options, weight, category, order_index) VALUES
('Apakah Anda pernah mencoba zat terlarang dalam 6 bulan terakhir?', 
  'yes_no', ARRAY['Ya', 'Tidak'], 10, 'perilaku', 1),

('Seberapa sering Anda merasa tertekan atau stres?',
  'multiple_choice', ARRAY['Tidak pernah', 'Jarang', 'Kadang-kadang', 'Sering', 'Sangat sering'], 
  7, 'kesehatan_mental', 2),

('Apakah ada anggota keluarga atau teman dekat yang menggunakan narkoba?',
  'yes_no', ARRAY['Ya', 'Tidak'], 8, 'lingkungan', 3),

('Seberapa mudah akses Anda terhadap zat terlarang?',
  'scale', ARRAY['Sangat sulit', 'Sulit', 'Netral', 'Mudah', 'Sangat mudah'],
  9, 'lingkungan', 4),

('Apakah Anda memahami bahaya dan konsekuensi hukum penggunaan narkoba?',
  'yes_no', ARRAY['Ya, sangat paham', 'Paham sebagian', 'Kurang paham', 'Tidak paham'],
  5, 'pengetahuan', 5);

-- Sample Emergency Contacts
INSERT INTO emergency_contacts (name, type, phone, description, is_available_24_7) VALUES
('BNN Hotline', 'hotline', '184', 'Layanan konsultasi dan informasi Badan Narkotika Nasional', true),
('RSJ Dr. Soeharto Heerdjan', 'rehab', '(021) 5682841', 'Rumah Sakit Jiwa dengan program rehabilitasi narkoba', false),
('Yayasan Rumah Cemara', 'support_group', '(022) 7272585', 'Komunitas dukungan sebaya untuk pengguna dan mantan pengguna narkoba', false);
