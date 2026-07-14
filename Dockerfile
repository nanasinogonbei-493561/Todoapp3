# マルチステージビルド - ビルドステージ
FROM gradle:8.4-jdk17 AS build

# 作業ディレクトリを設定
WORKDIR /app

# Gradleファイルをコピー
COPY build.gradle settings.gradle ./
COPY gradle ./gradle
COPY gradlew ./

# 依存関係をダウンロード
RUN gradle dependencies --no-daemon

# ソースコードをコピー
COPY src ./src

# アプリケーションをビルド
RUN gradle bootJar --no-daemon

# 実行ステージ
FROM openjdk:17-jre-slim

# メタデータを設定
LABEL maintainer="Todo Application Team"
LABEL version="1.0.0"
LABEL description="Todo Application with Spring Boot"

# 作業ディレクトリを設定
WORKDIR /app

# 文字エンコーディング設定
ENV LANG=ja_JP.UTF-8
ENV LC_ALL=ja_JP.UTF-8
ENV JAVA_OPTS="-Dfile.encoding=UTF-8 -Duser.language=ja -Duser.country=JP"

# アプリケーションファイルをコピー
COPY --from=build /app/build/libs/todo-0.0.1-SNAPSHOT.jar app.jar

# ログディレクトリを作成
RUN mkdir -p /app/logs

# ヘルスチェック用のポートを公開
EXPOSE 8080

# ヘルスチェックを設定
HEALTHCHECK --interval=30s --timeout=3s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:8080/actuator/health || exit 1

# アプリケーション起動
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"] 