--liquibase formatted sql

--changeset Consolidated:001_init_schema
-- =============================================================================
-- LMH Web Application Consolidated Database Schema
-- =============================================================================

-- 1. Table: Language
CREATE TABLE IF NOT EXISTS language (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    note TEXT,
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    delete_flag BOOLEAN DEFAULT FALSE,
    language_code VARCHAR(20) UNIQUE
);

-- Initial Data for Language
INSERT INTO language (created_at, delete_flag, name, note, updated_at, language_code)
VALUES (NOW(), false, 'English', 'Test language', NOW(), 'en')
ON CONFLICT (language_code) DO NOTHING;

-- 2. Table: Level
CREATE TABLE IF NOT EXISTS level (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    description TEXT,
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    delete_flag BOOLEAN DEFAULT FALSE,
    language_id INTEGER,
    FOREIGN KEY (language_id) REFERENCES language(id)
);

-- 3. Table: Users
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    username VARCHAR(100) UNIQUE,
    email VARCHAR(100) UNIQUE,
    phone_number VARCHAR(20),
    date_birth DATE,
    school VARCHAR(100),
    password VARCHAR(255),
    role VARCHAR(50),
    point INTEGER,
    credit INTEGER,
    created_at TIMESTAMP,
    last_login TIMESTAMP,
    delete_flag BOOLEAN DEFAULT FALSE,
    enable BOOLEAN DEFAULT FALSE,
    api_key VARCHAR(255),
    api_url VARCHAR(255)
);

-- 4. Table: Verification Token
CREATE TABLE IF NOT EXISTS verification_token (
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    token VARCHAR(255),
    expired_time TIMESTAMP,
    token_type VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_user_verification FOREIGN KEY (user_id) REFERENCES users(id)
);

-- 5. Table: Topic
CREATE TABLE IF NOT EXISTS topic (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    description TEXT,
    delete_flag BOOLEAN DEFAULT FALSE,
    type VARCHAR(50) CHECK (type IN ('USER_CREATION', 'DEFAULT')),
    note TEXT,
    created_at TIMESTAMP,
    image_url VARCHAR(500),
    image_id VARCHAR(255),
    user_id INTEGER,
    language_id INTEGER,
    level_id INTEGER,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (language_id) REFERENCES language(id),
    FOREIGN KEY (level_id) REFERENCES level(id)
);

-- 6. Table: Lesson
CREATE TABLE IF NOT EXISTS lesson (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    paragraph TEXT,
    note TEXT,
    description TEXT,
    status VARCHAR(50),
    delete_flag BOOLEAN DEFAULT FALSE,
    type VARCHAR(50) CHECK (type IN ('USER_CREATION', 'DEFAULT')),
    last_practice TIMESTAMP,
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    topic_id INTEGER,
    user_id INTEGER,
    language_id INTEGER,
    level_id INTEGER,
    FOREIGN KEY (topic_id) REFERENCES topic(id),
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- 7. Table: Status Lesson
CREATE TABLE IF NOT EXISTS status_lesson (
    id SERIAL PRIMARY KEY,
    name_status VARCHAR(20)
);

-- 8. Table: Status Lesson User
CREATE TABLE IF NOT EXISTS status_leson_user (
    id SERIAL PRIMARY KEY,
    user_id INTEGER,
    lesson_id INTEGER,
    status INTEGER,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (lesson_id) REFERENCES lesson(id),
    FOREIGN KEY (status) REFERENCES status_lesson(id)
);

-- 9. Table: Suggest Vocabulary
CREATE TABLE IF NOT EXISTS suggest_vocabulary (
    id SERIAL PRIMARY KEY,
    term VARCHAR(100),
    vietnamese TEXT,
    type VARCHAR(50),
    pronunciation VARCHAR(100),
    example TEXT,
    delete_flag BOOLEAN DEFAULT FALSE,
    lesson_id INTEGER,
    FOREIGN KEY (lesson_id) REFERENCES lesson(id)
);

-- 10. Table: History
CREATE TABLE IF NOT EXISTS history (
    id SERIAL PRIMARY KEY,
    question TEXT,
    answer TEXT,
    result TEXT,
    user_id INTEGER,
    lesson_id INTEGER,
    created_at TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (lesson_id) REFERENCES lesson(id)
);

-- 11. Table: Collection Vocabulary
CREATE TABLE IF NOT EXISTS collectionvoca (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    user_id INTEGER,
    CONSTRAINT fk_collectionvoca_user FOREIGN KEY (user_id) REFERENCES users(id)
);

-- 12. Table: Vocabulary
CREATE TABLE IF NOT EXISTS vocabulary (
    id SERIAL PRIMARY KEY,
    term VARCHAR(100),
    vi TEXT,
    type VARCHAR(50),
    pronunciation VARCHAR(100),
    example TEXT,
    audio_url VARCHAR(500),
    image_url VARCHAR(255),
    collection_id INTEGER,
    user_id INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (collection_id) REFERENCES collectionvoca(id),
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- 13. Table: Flash Card
CREATE TABLE IF NOT EXISTS flash_card (
    id SERIAL PRIMARY KEY,
    image_url VARCHAR(500),
    vocab_id INTEGER,
    FOREIGN KEY (vocab_id) REFERENCES vocabulary(id)
);

-- 14. Table: Notification
CREATE TABLE IF NOT EXISTS notification (
    id SERIAL PRIMARY KEY,
    type VARCHAR(50),
    message TEXT,
    link VARCHAR(255),
    created_at TIMESTAMP,
    is_read BOOLEAN DEFAULT FALSE,
    user_sender INTEGER,
    user_receive INTEGER,
    FOREIGN KEY (user_sender) REFERENCES users(id),
    FOREIGN KEY (user_receive) REFERENCES users(id)
);

-- 15. Table: Payment
CREATE TABLE IF NOT EXISTS payment (
    id SERIAL PRIMARY KEY,
    created_at TIMESTAMP,
    price DECIMAL(10,2),
    status VARCHAR(50),
    user_id INTEGER,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- 16. Table: Feedback
CREATE TABLE IF NOT EXISTS feedback (
    id SERIAL PRIMARY KEY,
    description TEXT,
    created_at TIMESTAMP,
    user_id INTEGER,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- 17. Table: Invalid Token
CREATE TABLE IF NOT EXISTS invalid_token (
    id VARCHAR(255) PRIMARY KEY,
    expiry_time TIMESTAMP(6) WITHOUT TIME ZONE
);
