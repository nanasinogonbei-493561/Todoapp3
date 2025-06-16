INSERT INTO categories (name, description) VALUES ('勉強', '勉強について');
INSERT INTO categories (name, description) VALUES ('運動', '運動について');
INSERT INTO categories (name, description) VALUES ('買い物', '買い物について');
INSERT INTO categories (name, description) VALUES ('家事', '家事について');


INSERT INTO tasks (category_id, summary, description, status) VALUES (1, 'Spring Boot を学ぶ', 'TODO アプリを作る', 'DONE');
INSERT INTO tasks (category_id, summary, description, status) VALUES (1, 'Spring Security を学ぶ', 'ログイン機能を作る', 'TODO');
