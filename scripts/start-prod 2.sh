#!/bin/bash

# 本番環境用起動スクリプト
# 文字化け対策を含む

set -e

# 環境変数ファイルを読み込み
if [ -f ".env.prod" ]; then
    echo "環境変数ファイルを読み込み中..."
    source .env.prod
else
    echo "警告: .env.prodファイルが見つかりません"
    echo "環境変数を手動で設定してください"
fi

# Java 17を使用
export JAVA_HOME=${JAVA_HOME:-/Users/sugawara/Library/Java/JavaVirtualMachines/ms-17.0.15/Contents/Home}

# 文字エンコーディング設定
export JAVA_OPTS="-Dfile.encoding=UTF-8 -Duser.language=ja -Duser.country=JP"

# 必須環境変数の確認
if [ -z "$MYSQL_URL" ] || [ -z "$MYSQL_USERNAME" ] || [ -z "$MYSQL_PASSWORD" ]; then
    echo "エラー: 必須の環境変数が設定されていません"
    echo "MYSQL_URL, MYSQL_USERNAME, MYSQL_PASSWORD を設定してください"
    exit 1
fi

echo "本番環境を起動中..."
echo "Java バージョン: $(java -version 2>&1 | head -1)"
echo "文字エンコーディング: $JAVA_OPTS"
echo "データベース: $MYSQL_URL"

# アプリケーション起動
java $JAVA_OPTS -jar \
  -Dspring.profiles.active=prod \
  -DMYSQL_URL="$MYSQL_URL" \
  -DMYSQL_USERNAME="$MYSQL_USERNAME" \
  -DMYSQL_PASSWORD="$MYSQL_PASSWORD" \
  -DDB_POOL_SIZE="${DB_POOL_SIZE:-10}" \
  -DSERVER_PORT="${SERVER_PORT:-8080}" \
  build/libs/todo-0.0.1-SNAPSHOT.jar 