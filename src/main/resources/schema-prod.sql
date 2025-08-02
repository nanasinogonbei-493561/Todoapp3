-- 本番環境用MySQLスキーマ
-- 既存のテーブルがあれば削除（注意: 本番環境ではデータが失われます）
DROP TABLE IF EXISTS tasks;
DROP TABLE IF EXISTS categories;

-- categories テーブル作成
CREATE TABLE categories (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(256) NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_name (name)
);

-- tasks テーブル作成
CREATE TABLE tasks (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    category_id BIGINT NOT NULL,
    summary VARCHAR(256) NOT NULL,
    description TEXT,
    status VARCHAR(256) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_category
        FOREIGN KEY (category_id) REFERENCES categories(id)
        ON DELETE CASCADE,
    INDEX idx_category_id (category_id),
    INDEX idx_status (status),
    INDEX idx_created_at (created_at)
);

-- 初期データ挿入
INSERT INTO categories (name, description) VALUES 
('仕事', '仕事関連のタスク'),
('プライベート', 'プライベート関連のタスク'),
('学習', '学習関連のタスク');

INSERT INTO tasks (category_id, summary, description, status) VALUES 
(1, 'プロジェクト計画書作成', '来月のプロジェクトの計画書を作成する', 'TODO'),
(1, '会議資料準備', '明日の会議用の資料を準備する', 'DOING'),
(2, '買い物', '週末の買い物リストを作成する', 'TODO'),
(3, 'Spring Boot学習', 'Spring Bootの基礎を学習する', 'DONE'); 