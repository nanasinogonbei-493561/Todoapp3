# デプロイメントガイド

## セキュリティ修正内容

### 1. 本番環境設定
- H2コンソールを無効化
- デバッグログを無効化
- エラーメッセージの詳細表示を無効化
- Thymeleafキャッシュを有効化

### 2. コード修正
- System.out.println文を削除
- パス変数の不整合を修正（`@DeleteMapping("{is}")` → `@DeleteMapping("{id}")`）
- CategoryServiceにdeleteメソッドを追加

### 3. データベース設定
- MySQL用の設定を追加
- 本番環境用のスキーマファイルを作成
- インデックスを追加してパフォーマンスを向上

## デプロイ手順

### 1. 環境変数の設定

#### 方法1: 自動設定スクリプト（推奨）
```bash
# 本番環境の環境変数を設定
./scripts/setup-env.sh prod

# 開発環境の環境変数を設定
./scripts/setup-env.sh dev
```

#### 方法2: 手動設定
```bash
# 環境変数ファイルを作成
cp env.example .env.prod

# 環境変数ファイルを編集（パスワード等を設定）
nano .env.prod

# 環境変数を読み込み
source .env.prod
```

#### 方法3: 直接設定
```bash
export MYSQL_URL=jdbc:mysql://your-mysql-host:3306/todo_prod?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true
export MYSQL_USERNAME=your_username
export MYSQL_PASSWORD=your_secure_password
export DB_POOL_SIZE=10
export SERVER_PORT=8080
```

### 2. MySQLデータベースの準備
```sql
-- MySQLに接続してデータベースを作成
CREATE DATABASE todo_prod CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- スキーマを実行
mysql -u your_username -p todo_prod < src/main/resources/schema-prod.sql
```

### 3. アプリケーションのビルドと実行
```bash
# 本番環境用プロファイルでビルド
./gradlew build -Dspring.profiles.active=prod

# 本番環境用プロファイルで実行
java -jar -Dspring.profiles.active=prod build/libs/todo-0.0.1-SNAPSHOT.jar
```

### 4. 本番環境での起動
```bash
# 環境変数とプロファイルを指定して起動
java -jar \
  -Dspring.profiles.active=prod \
  -DMYSQL_URL=$MYSQL_URL \
  -DMYSQL_USERNAME=$MYSQL_USERNAME \
  -DMYSQL_PASSWORD=$MYSQL_PASSWORD \
  build/libs/todo-0.0.1-SNAPSHOT.jar
```

## セキュリティチェックリスト

- [x] H2コンソールを無効化
- [x] デバッグログを無効化
- [x] System.out.println文を削除
- [x] エラーメッセージの詳細表示を無効化
- [x] 入力値検証を確認
- [x] SQLインジェクション対策（JPA使用）
- [x] XSS対策（Thymeleaf使用）
- [x] CSRF対策（Spring Boot標準）

## 注意事項

1. **データベース接続**: 本番環境では適切なMySQL接続設定が必要
2. **パスワード**: 環境変数で安全に管理
3. **SSL**: 本番環境ではSSL接続を推奨
4. **バックアップ**: 定期的なデータベースバックアップを実施
5. **ログ監視**: アプリケーションログの監視を設定 