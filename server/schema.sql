-- Admin users
CREATE TABLE IF NOT EXISTS admin_users (
  id SERIAL PRIMARY KEY,
  username TEXT UNIQUE NOT NULL,
  password_hash TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Free-form singleton content sections (hero, about, contact, marquee...)
-- data is a JSONB blob: { uz: {...}, uz_cyr: {...}, en: {...}, ru: {...}, <non-translated fields> }
CREATE TABLE IF NOT EXISTS site_content (
  section TEXT PRIMARY KEY,
  data JSONB NOT NULL DEFAULT '{}'::jsonb,
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- "Men haqimda" statistics (20+ Loyihalar, 2+ Yil tajriba, ...)
CREATE TABLE IF NOT EXISTS stats (
  id SERIAL PRIMARY KEY,
  order_index INT NOT NULL DEFAULT 0,
  count INT NOT NULL DEFAULT 0,
  label JSONB NOT NULL DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Skills list (icon/image + name + percent)
CREATE TABLE IF NOT EXISTS skills (
  id SERIAL PRIMARY KEY,
  order_index INT NOT NULL DEFAULT 0,
  image_url TEXT,
  percent INT NOT NULL DEFAULT 0,
  name JSONB NOT NULL DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Projects (full catalog; "featured" ones show on the home page, selected by admin)
CREATE TABLE IF NOT EXISTS projects (
  id SERIAL PRIMARY KEY,
  slug TEXT UNIQUE NOT NULL,
  order_index INT NOT NULL DEFAULT 0,
  featured BOOLEAN NOT NULL DEFAULT false,
  featured_order INT NOT NULL DEFAULT 0,
  image_url TEXT,
  screenshots JSONB NOT NULL DEFAULT '[]'::jsonb,
  video_url TEXT,
  rating NUMERIC(2,1) NOT NULL DEFAULT 5.0,
  link TEXT DEFAULT '#',
  github_link TEXT DEFAULT '#',
  tags JSONB NOT NULL DEFAULT '[]'::jsonb,
  title JSONB NOT NULL DEFAULT '{}'::jsonb,
  tagline JSONB NOT NULL DEFAULT '{}'::jsonb,
  description JSONB NOT NULL DEFAULT '{}'::jsonb,
  category JSONB NOT NULL DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Social / contact links (telegram, telegram channel, github, facebook, instagram...)
CREATE TABLE IF NOT EXISTS social_links (
  id SERIAL PRIMARY KEY,
  platform TEXT UNIQUE NOT NULL,
  url TEXT NOT NULL DEFAULT '',
  order_index INT NOT NULL DEFAULT 0
);

-- Play-Store style reviews per project, with a single admin reply
CREATE TABLE IF NOT EXISTS reviews (
  id SERIAL PRIMARY KEY,
  project_id INT NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
  comment TEXT NOT NULL,
  admin_reply TEXT,
  replied_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Idempotent column additions for databases created before these fields existed
ALTER TABLE projects ADD COLUMN IF NOT EXISTS screenshots JSONB NOT NULL DEFAULT '[]'::jsonb;
ALTER TABLE projects ADD COLUMN IF NOT EXISTS video_url TEXT;
ALTER TABLE projects ADD COLUMN IF NOT EXISTS logo_url TEXT;
ALTER TABLE projects ADD COLUMN IF NOT EXISTS author_name TEXT NOT NULL DEFAULT 'Sardorxon Valiyev';
ALTER TABLE projects ADD COLUMN IF NOT EXISTS views_count INT NOT NULL DEFAULT 0;
ALTER TABLE projects ADD COLUMN IF NOT EXISTS video_poster_url TEXT;

CREATE INDEX IF NOT EXISTS idx_reviews_project ON reviews(project_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_projects_featured ON projects(featured, featured_order);

-- Contact form submissions
CREATE TABLE IF NOT EXISTS messages (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  email TEXT NOT NULL,
  subject TEXT NOT NULL,
  message TEXT NOT NULL,
  is_read BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_messages_created ON messages(created_at DESC);
