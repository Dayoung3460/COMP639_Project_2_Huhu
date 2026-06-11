-- =============================================================
-- group_updates_hub_migration.sql -- Group Updates & Shared Knowledge Hub (P2-107)
-- COMP639 Group Project 2, Team Huhu -- Lincoln University
-- Run AFTER create_tables.sql + populate_tables.sql. Idempotent.
-- =============================================================

BEGIN;

-- ---- Group Updates ---------------------------------------------------
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'update_status_enum') THEN
        CREATE TYPE update_status_enum AS ENUM ('draft', 'published', 'removed');
    END IF;
END $$;

CREATE TABLE IF NOT EXISTS group_updates (
    update_id    SERIAL PRIMARY KEY,
    group_id     INT NOT NULL REFERENCES groups(group_id) ON DELETE CASCADE,
    author_id    INT REFERENCES users(user_id) ON DELETE SET NULL,
    title        VARCHAR(255) NOT NULL,
    body         TEXT NOT NULL,
    status       update_status_enum NOT NULL DEFAULT 'draft',
    created_at   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    published_at TIMESTAMP,
    updated_at   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    removed_at   TIMESTAMP
);
CREATE INDEX IF NOT EXISTS idx_group_updates_group_status
    ON group_updates (group_id, status, published_at DESC);

-- Multi-photo: one update can have many photos (the AC says "one or more").
CREATE TABLE IF NOT EXISTS group_update_photos (
    photo_id   SERIAL PRIMARY KEY,
    update_id  INT NOT NULL REFERENCES group_updates(update_id) ON DELETE CASCADE,
    photo_path VARCHAR(500) NOT NULL,
    display_order INT NOT NULL DEFAULT 0,
    uploaded_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS group_update_likes (
    update_id INT NOT NULL REFERENCES group_updates(update_id) ON DELETE CASCADE,
    user_id   INT NOT NULL REFERENCES users(user_id)          ON DELETE CASCADE,
    liked_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (update_id, user_id)
);

DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'update_comment_status_enum') THEN
        CREATE TYPE update_comment_status_enum AS ENUM ('visible', 'removed');
    END IF;
END $$;

CREATE TABLE IF NOT EXISTS group_update_comments (
    comment_id  SERIAL PRIMARY KEY,
    update_id   INT NOT NULL REFERENCES group_updates(update_id) ON DELETE CASCADE,
    author_id   INT REFERENCES users(user_id) ON DELETE SET NULL,
    body        TEXT NOT NULL,
    status      update_comment_status_enum NOT NULL DEFAULT 'visible',
    created_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    removed_at  TIMESTAMP,
    removed_by  INT REFERENCES users(user_id) ON DELETE SET NULL
);
CREATE INDEX IF NOT EXISTS idx_update_comments_update
    ON group_update_comments (update_id, created_at);

-- ---- Shared Knowledge Hub --------------------------------------------
CREATE TABLE IF NOT EXISTS knowledge_categories (
    category_id SERIAL PRIMARY KEY,
    slug        VARCHAR(60) UNIQUE NOT NULL,
    name        VARCHAR(120) NOT NULL,
    description TEXT,
    display_order INT NOT NULL DEFAULT 0
);

INSERT INTO knowledge_categories (slug, name, description, display_order)
VALUES
    ('trap-management',  'Trap management',  'Setting, maintaining, and inspecting traps.', 1),
    ('bait-stations',    'Bait stations',    'Bait choice, monitoring, and safe handling.', 2),
    ('seasonal-advice',  'Seasonal advice',  'Strategy that changes with the seasons.',     3),
    ('species-id',       'Species ID',       'Identifying captures and signs.',             4),
    ('safety',           'Safety',           'Personal and animal-welfare guidance.',       5)
ON CONFLICT (slug) DO NOTHING;

DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'knowledge_status_enum') THEN
        CREATE TYPE knowledge_status_enum AS ENUM
            ('draft', 'pending_review', 'published', 'rejected', 'archived');
    END IF;
END $$;

CREATE TABLE IF NOT EXISTS knowledge_articles (
    article_id      SERIAL PRIMARY KEY,
    category_id     INT NOT NULL REFERENCES knowledge_categories(category_id),
    title           VARCHAR(255) NOT NULL,
    body            TEXT NOT NULL,
    summary         VARCHAR(500),
    author_id       INT REFERENCES users(user_id) ON DELETE SET NULL,
    author_group_id INT REFERENCES groups(group_id) ON DELETE SET NULL,
    status          knowledge_status_enum NOT NULL DEFAULT 'draft',
    is_featured     BOOL NOT NULL DEFAULT FALSE,
    current_version INT  NOT NULL DEFAULT 1,
    reviewed_by     INT REFERENCES users(user_id) ON DELETE SET NULL,
    reviewed_at     TIMESTAMP,
    review_note     TEXT,
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    published_at    TIMESTAMP,
    updated_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX IF NOT EXISTS idx_articles_status_cat
    ON knowledge_articles (status, category_id, published_at DESC);
CREATE INDEX IF NOT EXISTS idx_articles_featured
    ON knowledge_articles (is_featured, published_at DESC)
    WHERE is_featured = TRUE AND status = 'published';

-- Multi-photo per article
CREATE TABLE IF NOT EXISTS knowledge_article_photos (
    photo_id    SERIAL PRIMARY KEY,
    article_id  INT NOT NULL REFERENCES knowledge_articles(article_id) ON DELETE CASCADE,
    photo_path  VARCHAR(500) NOT NULL,
    display_order INT NOT NULL DEFAULT 0
);

-- Append-only version history (snapshot per edit)
CREATE TABLE IF NOT EXISTS knowledge_article_versions (
    version_id   SERIAL PRIMARY KEY,
    article_id   INT NOT NULL REFERENCES knowledge_articles(article_id) ON DELETE CASCADE,
    version_no   INT NOT NULL,
    title        VARCHAR(255) NOT NULL,
    body         TEXT NOT NULL,
    summary      VARCHAR(500),
    edited_by    INT REFERENCES users(user_id) ON DELETE SET NULL,
    edited_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    note         TEXT,
    UNIQUE (article_id, version_no)
);

-- Moderation action log -- the CSV explicitly asks "The action and who
-- performed it are recorded."
CREATE TABLE IF NOT EXISTS knowledge_moderation_log (
    log_id      SERIAL PRIMARY KEY,
    article_id  INT NOT NULL REFERENCES knowledge_articles(article_id) ON DELETE CASCADE,
    actor_id    INT REFERENCES users(user_id) ON DELETE SET NULL,
    action      VARCHAR(20) NOT NULL CHECK (action IN ('approved','rejected','featured','unfeatured','versioned')),
    note        TEXT,
    created_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMIT;
