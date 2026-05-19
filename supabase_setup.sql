-- =============================================
-- 高中同學 40 週年同學會 — Supabase 資料庫設定
-- 請到 Supabase Dashboard > SQL Editor 貼上執行
-- =============================================


-- ===== 1. 報名資料表 =====
CREATE TABLE IF NOT EXISTS signups (
    id         UUID        DEFAULT gen_random_uuid() PRIMARY KEY,
    name       TEXT        NOT NULL,
    class_num  TEXT,
    phone      TEXT        NOT NULL,
    email      TEXT,
    event_type TEXT        NOT NULL,
    guests     INTEGER     DEFAULT 0,
    diet       TEXT        DEFAULT 'none',
    message    TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- RLS：任何人可送出報名，資料只能透過 Dashboard / Service Key 查閱
ALTER TABLE signups ENABLE ROW LEVEL SECURITY;

CREATE POLICY "允許公開報名"
    ON signups FOR INSERT TO anon
    WITH CHECK (true);


-- ===== 2. BBS 文章資料表 =====
CREATE TABLE IF NOT EXISTS bbs_posts (
    id         UUID        DEFAULT gen_random_uuid() PRIMARY KEY,
    category   TEXT        NOT NULL DEFAULT '[閒聊]',
    title      TEXT        NOT NULL,
    author     TEXT        NOT NULL,
    body       TEXT        NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE bbs_posts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "允許公開讀取文章"
    ON bbs_posts FOR SELECT TO anon
    USING (true);

CREATE POLICY "允許公開發文"
    ON bbs_posts FOR INSERT TO anon
    WITH CHECK (true);


-- ===== 3. BBS 留言資料表 =====
CREATE TABLE IF NOT EXISTS bbs_comments (
    id         UUID        DEFAULT gen_random_uuid() PRIMARY KEY,
    post_id    UUID        NOT NULL REFERENCES bbs_posts(id) ON DELETE CASCADE,
    tag        TEXT        DEFAULT '→' CHECK (tag IN ('推', '噓', '→')),
    userid     TEXT        NOT NULL,
    content    TEXT        NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE bbs_comments ENABLE ROW LEVEL SECURITY;

CREATE POLICY "允許公開讀取留言"
    ON bbs_comments FOR SELECT TO anon
    USING (true);

CREATE POLICY "允許公開留言"
    ON bbs_comments FOR INSERT TO anon
    WITH CHECK (true);


-- ===== 4. 照片紀錄資料表 =====
CREATE TABLE IF NOT EXISTS gallery_photos (
    id         UUID        DEFAULT gen_random_uuid() PRIMARY KEY,
    filename   TEXT        NOT NULL,
    url        TEXT        NOT NULL,
    category   TEXT        DEFAULT 'upload',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE gallery_photos ENABLE ROW LEVEL SECURITY;

CREATE POLICY "允許公開讀取照片"
    ON gallery_photos FOR SELECT TO anon
    USING (true);

CREATE POLICY "允許公開新增照片紀錄"
    ON gallery_photos FOR INSERT TO anon
    WITH CHECK (true);


-- =============================================
-- 5. Storage Bucket 設定（照片上傳用）
-- 請到 Supabase Dashboard > Storage > New Bucket
--   Bucket 名稱：photos
--   Public bucket：開啟
-- 然後在 Bucket > Policies 新增：
--   INSERT policy → anon（允許上傳）
--   SELECT policy → anon（允許公開讀取）
-- =============================================
-- 若你有 Service Role 權限，也可直接執行：
-- INSERT INTO storage.buckets (id, name, public)
--     VALUES ('photos', 'photos', true)
--     ON CONFLICT (id) DO UPDATE SET public = true;
--
-- CREATE POLICY "允許公開上傳"
--     ON storage.objects FOR INSERT TO anon
--     WITH CHECK (bucket_id = 'photos');
--
-- CREATE POLICY "允許公開讀取"
--     ON storage.objects FOR SELECT TO anon
--     USING (bucket_id = 'photos');


-- ===== 6. 選填：測試用初始資料 =====
-- INSERT INTO bbs_posts (category, title, author, body) VALUES
-- ('[公告]', '40週年同學會確定舉辦！', '班長小明',
--  '各位親愛的同學們，我們的40週年同學會終於確定了！時間：2026/6/20，地點：圓山大飯店金龍廳。');
