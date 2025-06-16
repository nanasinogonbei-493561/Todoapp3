-- H2では FOREIGN_KEY_CHECKS を使わない


-- 既存のテーブルがあれば削除
DROP TABLE IF EXISTS tasks;
DROP TABLE IF EXISTS categories;


-- categories テーブル作成
CREATE TABLE categories (
 id BIGINT PRIMARY KEY AUTO_INCREMENT,
 name VARCHAR(256) NOT NULL,
 description TEXT
);


-- tasks テーブル作成
CREATE TABLE tasks (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  category_id BIGINT NOT NULL,
  summary VARCHAR(256) NOT NULL,
  description TEXT,
  status VARCHAR(256) NOT NULL,
  CONSTRAINT fk_category
     FOREIGN KEY (category_id) REFERENCES categories(id)
     ON DELETE CASCADE
);