# Docker本番環境

## 概要
このプロジェクトはDockerを使用した本番環境を提供します。MySQLデータベース、Spring Bootアプリケーション、Nginxリバースプロキシが含まれています。

## アーキテクチャ

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   Nginx     │    │ Spring Boot │    │   MySQL     │
│  (Port 80)  │───▶│  (Port 8080)│───▶│  (Port 3306)│
│  Reverse    │    │ Application │    │  Database   │
│   Proxy     │    │             │    │             │
└─────────────┘    └─────────────┘    └─────────────┘
```

## 前提条件

- Docker
- Docker Compose
- 4GB以上のメモリ
- 10GB以上のディスク容量

## クイックスタート

### 1. 環境変数の設定
```bash
# 環境変数ファイルをコピー
cp docker.env docker.env.local

# パスワード等を編集（本番環境では必須）
nano docker.env.local
```

### 2. 環境の起動
```bash
# 管理スクリプトを使用（推奨）
./scripts/docker-manage.sh build
./scripts/docker-manage.sh start

# または直接docker-composeを使用
docker-compose up -d
```

### 3. アクセス
- **アプリケーション**: http://localhost
- **MySQL**: localhost:3306
- **ヘルスチェック**: http://localhost/health

## 管理コマンド

### 基本操作
```bash
# ビルド
./scripts/docker-manage.sh build

# 起動
./scripts/docker-manage.sh start

# 停止
./scripts/docker-manage.sh stop

# 再起動
./scripts/docker-manage.sh restart

# 状態確認
./scripts/docker-manage.sh status

# ログ表示
./scripts/docker-manage.sh logs
```

### データベース操作
```bash
# データベースに接続
./scripts/docker-manage.sh db-shell

# バックアップ
./scripts/docker-manage.sh backup

# 復元
./scripts/docker-manage.sh restore backups/todo_backup_20231201_120000.sql
```

### コンテナ操作
```bash
# アプリケーションコンテナに接続
./scripts/docker-manage.sh shell

# クリーンアップ（注意: データが失われます）
./scripts/docker-manage.sh clean
```

## 環境変数

### 必須設定
```bash
# MySQL設定
MYSQL_ROOT_PASSWORD=your_secure_root_password
MYSQL_DATABASE=todo_prod
MYSQL_USER=todo_user
MYSQL_PASSWORD=your_secure_password

# アプリケーション設定
SERVER_PORT=8080
```

### オプション設定
```bash
# データベース接続プール
DB_POOL_SIZE=10

# アプリケーション情報
APP_NAME=Todo Application
APP_VERSION=1.0.0
APP_ENVIRONMENT=production
LOG_LEVEL=WARN
```

## セキュリティ

### 本番環境での設定
1. **パスワードの変更**: デフォルトパスワードを必ず変更
2. **ネットワーク分離**: 本番環境では外部ネットワークアクセスを制限
3. **SSL/TLS**: 本番環境ではHTTPSを有効化
4. **ファイアウォール**: 不要なポートを閉じる

### セキュリティチェックリスト
- [ ] デフォルトパスワードを変更
- [ ] 環境変数ファイルの権限を600に設定
- [ ] 本番環境ではNginxのSSL設定を追加
- [ ] データベースの外部アクセスを制限
- [ ] ログファイルの権限を適切に設定

## トラブルシューティング

### よくある問題

#### 1. ポート競合
```bash
# 使用中のポートを確認
lsof -i :80
lsof -i :3306

# 競合するプロセスを停止
sudo pkill -f "nginx"
sudo pkill -f "mysql"
```

#### 2. メモリ不足
```bash
# Dockerのメモリ制限を確認
docker stats

# 不要なコンテナを削除
docker system prune -a
```

#### 3. データベース接続エラー
```bash
# MySQLコンテナの状態確認
docker-compose logs mysql

# データベースに直接接続
./scripts/docker-manage.sh db-shell
```

#### 4. 文字化け
```bash
# アプリケーションログを確認
docker-compose logs app

# データベースの文字セット確認
./scripts/docker-manage.sh db-shell
SHOW VARIABLES LIKE 'character_set%';
```

### ログの確認
```bash
# 全サービスのログ
docker-compose logs

# 特定サービスのログ
docker-compose logs app
docker-compose logs mysql
docker-compose logs nginx

# リアルタイムログ
docker-compose logs -f
```

## パフォーマンス最適化

### 1. リソース制限
```yaml
# docker-compose.ymlに追加
services:
  app:
    deploy:
      resources:
        limits:
          memory: 1G
          cpus: '0.5'
```

### 2. データベース最適化
```sql
-- MySQL設定の調整
SET GLOBAL innodb_buffer_pool_size = 512M;
SET GLOBAL max_connections = 200;
```

### 3. キャッシュ設定
```yaml
# Nginxキャッシュ設定
location ~* \.(css|js|png|jpg|jpeg|gif|ico)$ {
    expires 1y;
    add_header Cache-Control "public, immutable";
}
```

## バックアップと復元

### 自動バックアップ
```bash
# バックアップスクリプトを作成
cat > backup-cron.sh << 'EOF'
#!/bin/bash
cd /path/to/project
./scripts/docker-manage.sh backup
EOF

# cronに追加（毎日午前2時にバックアップ）
0 2 * * * /path/to/backup-cron.sh
```

### 復元手順
```bash
# 1. 環境を停止
./scripts/docker-manage.sh stop

# 2. データベースボリュームを削除
docker volume rm spring-boot-introduction-main_mysql_data

# 3. 環境を起動
./scripts/docker-manage.sh start

# 4. データを復元
./scripts/docker-manage.sh restore backups/todo_backup_YYYYMMDD_HHMMSS.sql
```

## 監視とアラート

### ヘルスチェック
```bash
# ヘルスチェックの確認
curl -f http://localhost/health

# 自動監視スクリプト
while true; do
    if ! curl -f http://localhost/health > /dev/null 2>&1; then
        echo "アプリケーションが応答しません: $(date)"
        # アラート送信処理
    fi
    sleep 30
done
```

### メトリクス収集
- Spring Boot Actuator: http://localhost/actuator/metrics
- MySQLメトリクス: データベース内の統計情報
- Nginxアクセスログ: `/var/log/nginx/access.log`

## 開発環境との違い

| 項目 | 開発環境 | 本番環境 |
|------|----------|----------|
| データベース | H2 (メモリ) | MySQL |
| ログレベル | DEBUG | WARN |
| キャッシュ | 無効 | 有効 |
| セキュリティ | 緩い | 厳格 |
| パフォーマンス | 低 | 高 |

## サポート

問題が発生した場合は以下を確認してください：

1. **ログファイル**: `docker-compose logs`
2. **ドキュメント**: `CHARSET_FIX.md`, `DEPLOYMENT.md`
3. **設定ファイル**: `docker-compose.yml`, `docker.env`
4. **スクリプト**: `scripts/docker-manage.sh help` 