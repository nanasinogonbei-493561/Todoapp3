#!/bin/bash

# ログ検索スクリプト
# 使用方法: ./search-logs.sh [検索キーワード] [ログファイル]

LOG_DIR="logs"
DEFAULT_LOG_FILE="application.json"

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
    echo "ログ検索スクリプト"
    echo ""
    echo "使用方法:"
    echo "  $0 [オプション] [検索キーワード]"
    echo ""
    echo "オプション:"
    echo "  -f, --file FILE     ログファイルを指定 (デフォルト: application.json)"
    echo "  -e, --error         エラーログのみを検索"
    echo "  -w, --warn          警告ログのみを検索"
    echo "  -t, --today         今日のログのみを検索"
    echo "  -j, --json          JSON形式で出力"
    echo "  -h, --help          このヘルプを表示"
    echo ""
    echo "例:"
    echo "  $0 ERROR                    # エラーを検索"
    echo "  $0 -e                       # エラーログのみ表示"
    echo "  $0 -f error.json Exception  # エラーファイルから例外を検索"
    echo "  $0 -t -w                    # 今日の警告ログを表示"
}

# 引数の解析
LOG_FILE="$DEFAULT_LOG_FILE"
SEARCH_KEYWORD=""
ERROR_ONLY=false
WARN_ONLY=false
TODAY_ONLY=false
JSON_OUTPUT=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -f|--file)
            LOG_FILE="$2"
            shift 2
            ;;
        -e|--error)
            ERROR_ONLY=true
            shift
            ;;
        -w|--warn)
            WARN_ONLY=true
            shift
            ;;
        -t|--today)
            TODAY_ONLY=true
            shift
            ;;
        -j|--json)
            JSON_OUTPUT=true
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        -*)
            print_error "不明なオプション: $1"
            show_help
            exit 1
            ;;
        *)
            SEARCH_KEYWORD="$1"
            shift
            ;;
    esac
done

# ログファイルの存在確認
if [[ ! -f "$LOG_DIR/$LOG_FILE" ]]; then
    print_error "ログファイルが見つかりません: $LOG_DIR/$LOG_FILE"
    exit 1
fi

print_info "ログファイル: $LOG_DIR/$LOG_FILE"

# 検索コマンドの構築
SEARCH_CMD="cat $LOG_DIR/$LOG_FILE"

# 今日のログのみをフィルタ
if [[ "$TODAY_ONLY" == true ]]; then
    TODAY=$(date +%Y-%m-%d)
    SEARCH_CMD="$SEARCH_CMD | grep '\"@timestamp\":\"$TODAY'"
fi

# ログレベルのフィルタ
if [[ "$ERROR_ONLY" == true ]]; then
    SEARCH_CMD="$SEARCH_CMD | grep '\"level\":\"ERROR'"
elif [[ "$WARN_ONLY" == true ]]; then
    SEARCH_CMD="$SEARCH_CMD | grep '\"level\":\"WARN'"
fi

# キーワード検索
if [[ -n "$SEARCH_KEYWORD" ]]; then
    SEARCH_CMD="$SEARCH_CMD | grep -i '$SEARCH_KEYWORD'"
fi

# JSON形式で出力
if [[ "$JSON_OUTPUT" == true ]]; then
    SEARCH_CMD="$SEARCH_CMD | jq '.'"
else
    # 見やすい形式で出力
    SEARCH_CMD="$SEARCH_CMD | jq -r '\"[\" + .\"@timestamp\" + \"] [\" + .level + \"] \" + .message'"
fi

# 検索実行
print_info "検索を実行中..."
eval $SEARCH_CMD

if [[ $? -eq 0 ]]; then
    print_success "検索完了"
else
    print_warn "検索結果が見つかりませんでした"
fi 