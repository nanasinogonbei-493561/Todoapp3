#!/bin/bash

# 環境変数設定スクリプト
# 使用方法: ./scripts/setup-env.sh [環境名]

ENVIRONMENT=${1:-prod}
ENV_FILE=".env.${ENVIRONMENT}"

# 色付き出力のための関数
print_error() {
    echo -e "\033[31m[ERROR]\033[0m $1"
}

print_warn() {
    echo -e "\033[33m[WARN]\033[0m $1"
}

print_info() {
    echo -e "\033[34m[INFO]\033[0m $1"
}

print_success() {
    echo -e "\033[32m[SUCCESS]\033[0m $1"
}

# ヘルプ表示
show_help() {
    echo "環境変数設定スクリプト"
    echo ""
    echo "使用方法:"
    echo "  $0 [環境名]"
    echo ""
    echo "環境名:"
    echo "  prod    本番環境 (デフォルト)"
    echo "  dev     開発環境"
    echo "  test    テスト環境"
    echo ""
    echo "例:"
    echo "  $0 prod    # 本番環境の環境変数を設定"
    echo "  $0 dev     # 開発環境の環境変数を設定"
}

# ヘルプ表示
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    show_help
    exit 0
fi

print_info "環境変数設定を開始: $ENVIRONMENT"

# 環境変数ファイルの存在確認
if [[ ! -f "$ENV_FILE" ]]; then
    print_warn "環境変数ファイルが見つかりません: $ENV_FILE"
    print_info "env.exampleをコピーして作成します..."
    cp env.example "$ENV_FILE"
    print_success "環境変数ファイルを作成しました: $ENV_FILE"
    print_warn "必ず設定値を編集してください！"
fi

# 環境変数ファイルを読み込み
if [[ -f "$ENV_FILE" ]]; then
    print_info "環境変数を読み込み中..."
    
    # ファイルから環境変数を読み込み
    while IFS= read -r line; do
        # コメント行と空行をスキップ
        if [[ ! "$line" =~ ^[[:space:]]*# ]] && [[ -n "$line" ]]; then
            # 環境変数を設定
            export "$line"
            print_info "設定: ${line%%=*}"
        fi
    done < "$ENV_FILE"
    
    print_success "環境変数の読み込みが完了しました"
else
    print_error "環境変数ファイルが見つかりません: $ENV_FILE"
    exit 1
fi

# 必須環境変数の確認
print_info "必須環境変数の確認中..."

REQUIRED_VARS=("MYSQL_URL" "MYSQL_USERNAME" "MYSQL_PASSWORD")
MISSING_VARS=()

for var in "${REQUIRED_VARS[@]}"; do
    if [[ -z "${!var}" ]]; then
        MISSING_VARS+=("$var")
    fi
done

if [[ ${#MISSING_VARS[@]} -gt 0 ]]; then
    print_error "以下の必須環境変数が設定されていません:"
    for var in "${MISSING_VARS[@]}"; do
        echo "  - $var"
    done
    print_warn "環境変数ファイルを編集してください: $ENV_FILE"
    exit 1
fi

print_success "すべての必須環境変数が設定されています"

# 環境変数の表示（パスワードは隠す）
print_info "現在の環境変数設定:"
echo "  MYSQL_URL: ${MYSQL_URL}"
echo "  MYSQL_USERNAME: ${MYSQL_USERNAME}"
echo "  MYSQL_PASSWORD: [HIDDEN]"
echo "  SERVER_PORT: ${SERVER_PORT:-8080}"
echo "  APP_ENVIRONMENT: ${APP_ENVIRONMENT:-production}"

print_success "環境変数設定が完了しました"
print_info "アプリケーションを起動するには:"
echo "  export JAVA_HOME=/Users/sugawara/Library/Java/JavaVirtualMachines/ms-17.0.15/Contents/Home"
echo "  ./gradlew bootRun -Dspring.profiles.active=$ENVIRONMENT" 