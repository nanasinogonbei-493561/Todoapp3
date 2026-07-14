#!/bin/bash

# Docker環境管理スクリプト

set -e

# 色付き出力
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ヘルプ表示
show_help() {
    echo "Docker環境管理スクリプト"
    echo ""
    echo "使用方法: $0 [コマンド]"
    echo ""
    echo "コマンド:"
    echo "  build     - Dockerイメージをビルド"
    echo "  start     - 環境を起動"
    echo "  stop      - 環境を停止"
    echo "  restart   - 環境を再起動"
    echo "  logs      - ログを表示"
    echo "  status    - コンテナの状態を表示"
    echo "  clean     - コンテナとイメージを削除"
    echo "  shell     - アプリケーションコンテナにシェル接続"
    echo "  db-shell  - MySQLコンテナにシェル接続"
    echo "  backup    - データベースをバックアップ"
    echo "  restore   - データベースを復元"
    echo "  help      - このヘルプを表示"
    echo ""
}

# 環境変数ファイルの確認
check_env_file() {
    if [ ! -f "docker.env" ]; then
        echo -e "${RED}エラー: docker.envファイルが見つかりません${NC}"
        echo "docker.env.exampleをコピーして設定してください"
        exit 1
    fi
}

# ビルド
build() {
    echo -e "${BLUE}Dockerイメージをビルド中...${NC}"
    docker-compose build --no-cache
    echo -e "${GREEN}ビルド完了${NC}"
}

# 起動
start() {
    check_env_file
    echo -e "${BLUE}Docker環境を起動中...${NC}"
    docker-compose up -d
    echo -e "${GREEN}起動完了${NC}"
    echo -e "${YELLOW}アプリケーション: http://localhost:80${NC}"
    echo -e "${YELLOW}MySQL: localhost:3306${NC}"
}

# 停止
stop() {
    echo -e "${BLUE}Docker環境を停止中...${NC}"
    docker-compose down
    echo -e "${GREEN}停止完了${NC}"
}

# 再起動
restart() {
    echo -e "${BLUE}Docker環境を再起動中...${NC}"
    docker-compose restart
    echo -e "${GREEN}再起動完了${NC}"
}

# ログ表示
logs() {
    echo -e "${BLUE}ログを表示中...${NC}"
    docker-compose logs -f
}

# 状態表示
status() {
    echo -e "${BLUE}コンテナの状態:${NC}"
    docker-compose ps
    echo ""
    echo -e "${BLUE}ヘルスチェック:${NC}"
    docker-compose ps --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}"
}

# クリーンアップ
clean() {
    echo -e "${YELLOW}警告: すべてのコンテナとイメージを削除します${NC}"
    read -p "続行しますか? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${BLUE}クリーンアップ中...${NC}"
        docker-compose down -v --rmi all
        docker system prune -f
        echo -e "${GREEN}クリーンアップ完了${NC}"
    else
        echo -e "${YELLOW}キャンセルしました${NC}"
    fi
}

# シェル接続
shell() {
    echo -e "${BLUE}アプリケーションコンテナに接続中...${NC}"
    docker-compose exec app /bin/bash
}

# データベースシェル接続
db_shell() {
    echo -e "${BLUE}MySQLコンテナに接続中...${NC}"
    docker-compose exec mysql mysql -u root -p${MYSQL_ROOT_PASSWORD:-rootpassword} ${MYSQL_DATABASE:-todo_prod}
}

# バックアップ
backup() {
    local backup_dir="backups"
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_file="${backup_dir}/todo_backup_${timestamp}.sql"
    
    mkdir -p "$backup_dir"
    echo -e "${BLUE}データベースをバックアップ中...${NC}"
    docker-compose exec mysql mysqldump -u root -p${MYSQL_ROOT_PASSWORD:-rootpassword} ${MYSQL_DATABASE:-todo_prod} > "$backup_file"
    echo -e "${GREEN}バックアップ完了: $backup_file${NC}"
}

# 復元
restore() {
    if [ -z "$1" ]; then
        echo -e "${RED}エラー: バックアップファイルを指定してください${NC}"
        echo "使用方法: $0 restore <backup_file>"
        exit 1
    fi
    
    local backup_file="$1"
    if [ ! -f "$backup_file" ]; then
        echo -e "${RED}エラー: バックアップファイルが見つかりません: $backup_file${NC}"
        exit 1
    fi
    
    echo -e "${YELLOW}警告: データベースを復元します。既存のデータは失われます${NC}"
    read -p "続行しますか? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${BLUE}データベースを復元中...${NC}"
        docker-compose exec -T mysql mysql -u root -p${MYSQL_ROOT_PASSWORD:-rootpassword} ${MYSQL_DATABASE:-todo_prod} < "$backup_file"
        echo -e "${GREEN}復元完了${NC}"
    else
        echo -e "${YELLOW}キャンセルしました${NC}"
    fi
}

# メイン処理
case "$1" in
    build)
        build
        ;;
    start)
        start
        ;;
    stop)
        stop
        ;;
    restart)
        restart
        ;;
    logs)
        logs
        ;;
    status)
        status
        ;;
    clean)
        clean
        ;;
    shell)
        shell
        ;;
    db-shell)
        db_shell
        ;;
    backup)
        backup
        ;;
    restore)
        restore "$2"
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        echo -e "${RED}エラー: 不明なコマンド '$1'${NC}"
        echo ""
        show_help
        exit 1
        ;;
esac 