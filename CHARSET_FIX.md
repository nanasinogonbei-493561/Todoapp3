# 本番環境での文字化け対策

## 概要
本番環境で日本語文字が正しく表示されない問題を解決するための設定と手順を説明します。

## 文字化けの原因

### 1. Java バージョンの問題
- Java 24では文字エンコーディング処理が変更されている
- Java 17を使用することで解決

### 2. データベース接続の文字エンコーディング
- MySQL接続時にUTF-8が正しく設定されていない
- データベーステーブルの文字セットが適切でない

### 3. アプリケーション設定の不足
- Spring Bootの文字エンコーディング設定が不十分
- JVM起動時の文字エンコーディング設定が不足

## 解決方法

### 1. Java 17の使用
```bash
# Java 17を明示的に指定
export JAVA_HOME=/Users/sugawara/Library/Java/JavaVirtualMachines/ms-17.0.15/Contents/Home
```

### 2. JVM起動オプション
```bash
# 文字エンコーディング設定
export JAVA_OPTS="-Dfile.encoding=UTF-8 -Duser.language=ja -Duser.country=JP"
```

### 3. Spring Boot設定
```properties
# 文字エンコーディング設定
server.servlet.encoding.charset=UTF-8
server.servlet.encoding.force=true
spring.http.encoding.charset=UTF-8
spring.http.encoding.force=true
```

### 4. データベース接続設定
```properties
# MySQL接続URLに文字エンコーディング設定を追加
spring.datasource.url=jdbc:mysql://localhost:3306/todo_prod?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true&characterEncoding=UTF-8&useUnicode=true

# JPA設定
spring.jpa.properties.hibernate.connection.characterEncoding=utf8
spring.jpa.properties.hibernate.connection.useUnicode=true
spring.jpa.properties.hibernate.connection.CharSet=utf8
```

### 5. データベーススキーマ設定
```sql
-- MySQL接続時の文字セット設定
SET NAMES utf8mb4;
SET CHARACTER SET utf8mb4;
SET character_set_connection=utf8mb4;

-- テーブル作成時の文字セット指定
CREATE TABLE categories (
    -- カラム定義
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

## 本番環境での起動手順

### 1. 環境変数の設定
```bash
# 環境変数ファイルを作成
cp env.example .env.prod

# 環境変数ファイルを編集
nano .env.prod
```

### 2. 起動スクリプトの使用（推奨）
```bash
# 本番環境用起動スクリプトを実行
./scripts/start-prod.sh
```

### 3. 手動起動
```bash
# Java 17と文字エンコーディング設定
export JAVA_HOME=/Users/sugawara/Library/Java/JavaVirtualMachines/ms-17.0.15/Contents/Home
export JAVA_OPTS="-Dfile.encoding=UTF-8 -Duser.language=ja -Duser.country=JP"

# アプリケーション起動
java $JAVA_OPTS -jar \
  -Dspring.profiles.active=prod \
  -DMYSQL_URL="$MYSQL_URL" \
  -DMYSQL_USERNAME="$MYSQL_USERNAME" \
  -DMYSQL_PASSWORD="$MYSQL_PASSWORD" \
  build/libs/todo-0.0.1-SNAPSHOT.jar
```

## 確認方法

### 1. ログの確認
```bash
# 文字化けがないかログを確認
tail -f logs/application.json | jq -r '.message'
```

### 2. Webアプリケーションの確認
```bash
# ブラウザでアクセス
curl -s http://localhost:8080 | grep -i "charset"
```

### 3. データベースの確認
```sql
-- MySQLで文字セットを確認
SHOW VARIABLES LIKE 'character_set%';
SHOW CREATE TABLE categories;
```

## トラブルシューティング

### 1. 文字化けが続く場合
- Java 17が正しく設定されているか確認
- データベースの文字セット設定を確認
- アプリケーション再起動

### 2. データベース接続エラー
- MySQL接続URLの文字エンコーディングパラメータを確認
- データベースサーバーの文字セット設定を確認

### 3. ログの文字化け
- logback-spring.xmlの設定を確認
- ファイルエンコーディングをUTF-8に設定

## 注意事項

- 本番環境では必ずJava 17を使用
- データベース接続URLに文字エンコーディング設定を含める
- テーブル作成時に文字セットを明示的に指定
- 環境変数で文字エンコーディング設定を管理 