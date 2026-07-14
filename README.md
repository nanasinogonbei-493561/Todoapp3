# 📋 Todo & Category 管理アプリケーション

> Spring Boot で構築した、**タスク管理 Web アプリケーション**です。
> 書籍の写経から出発し、**独自機能の追加・セキュリティ強化・構造化ログ・Docker による本番環境構築**まで、自力で拡張しました。

<p align="left">
  <img src="https://img.shields.io/badge/Java-17-orange?logo=openjdk&logoColor=white" alt="Java 17">
  <img src="https://img.shields.io/badge/Spring%20Boot-3.1.2-6DB33F?logo=springboot&logoColor=white" alt="Spring Boot 3.1.2">
  <img src="https://img.shields.io/badge/MySQL-8.0-4479A1?logo=mysql&logoColor=white" alt="MySQL 8.0">
  <img src="https://img.shields.io/badge/Docker-Compose-2496ED?logo=docker&logoColor=white" alt="Docker">
  <img src="https://img.shields.io/badge/Thymeleaf-005F0F?logo=thymeleaf&logoColor=white" alt="Thymeleaf">
  <img src="https://img.shields.io/badge/Bootstrap-5.2-7952B3?logo=bootstrap&logoColor=white" alt="Bootstrap 5">
</p>

---

## 👀 3行で言うと

- **タスク（Todo）とカテゴリを CRUD で管理**できる、実用的な Web アプリです。
- **開発環境（H2）と本番環境（MySQL + Nginx）を Docker で切り替え**られる構成を、一から作りました。
- 「動けば OK」で終わらせず、**構造化ログ・ヘルスチェック・例外ハンドリング・入力バリデーション**まで運用を意識して実装しました。

---

## ✨ できること

| 機能 | 内容 |
| :--- | :--- |
| ✅ タスク管理 | タスクの一覧・詳細・登録・編集・削除（CRUD 一式） |
| 🏷️ カテゴリ管理 | カテゴリの CRUD。タスクをカテゴリに紐づけて分類 |
| 🔄 ステータス管理 | `TODO` / `DOING` / `DONE` の 3 状態で進捗を可視化 |
| 🛡️ 入力バリデーション | Bean Validation による入力チェックとエラー表示 |
| 🚫 エラーハンドリング | 専用の 404 ページ・エラーページを用意し、例外を握りつぶさない設計 |
| 📊 構造化ログ | 処理時間・操作内容を JSON 形式で出力し、運用時の追跡を容易に |
| ❤️ ヘルスチェック | Spring Boot Actuator による死活監視エンドポイント |

> ℹ️ 元の教材にあった検索機能を、実装を理解した上で **カテゴリ分類機能へと再設計**しました。単なる写経で終わらせず、自分で仕様を考えて作り替えた部分です。

---

## 🧱 アーキテクチャ

責務ごとにレイヤーを分けた、Spring MVC の王道構成で実装しています。

```
Controller  →  Service  →  Repository  →  Database
（画面・入力）  （業務ロジック）  （データ操作）    （H2 / MySQL）
```

本番環境は 3 つのコンテナで構成しています。

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   Nginx     │    │ Spring Boot │    │   MySQL     │
│  (Port 80)  │──▶│  (Port 8080)│──▶│  (Port 3306)│
│ リバースプロキシ │    │  アプリ本体    │    │  データベース   │
└─────────────┘    └─────────────┘    └─────────────┘
```

---

## 🛠️ 使用技術

| 分類 | 技術 |
| :--- | :--- |
| 言語 | Java 17 |
| フレームワーク | Spring Boot 3.1.2（Web / Validation / Actuator / Data JPA） |
| ビュー | Thymeleaf ＋ Thymeleaf Layout Dialect ／ Bootstrap 5 |
| データアクセス | MyBatis ／ Spring Data JPA |
| データベース | H2（開発）／ MySQL 8.0（本番） |
| ログ | Logback ＋ logstash-logback-encoder（JSON 構造化ログ） |
| インフラ | Docker（マルチステージビルド）／ Docker Compose ／ Nginx |
| ビルド | Gradle |
| 開発環境 | IntelliJ IDEA Community Edition |

---

## 🚀 動かしてみる

### 開発環境（最短で試す）

H2 インメモリ DB を使うため、**Java 17 があればそのまま起動できます。**

```bash
./gradlew bootRun
```

ブラウザで **http://localhost:8080/tasks** にアクセスしてください。

### 本番相当環境（Docker）

MySQL・アプリ・Nginx を Docker Compose でまとめて起動します。

```bash
docker-compose up -d
```

起動後、**http://localhost** でアクセスできます。
（詳細な手順・管理コマンドは [DOCKER_README.md](DOCKER_README.md) を参照）

---

## 💡 工夫したポイント（技術的なこだわり）

- **環境ごとの設定分離**
  `application.properties` と `application-prod.properties` を Spring Profiles で切り替え、開発（H2）と本番（MySQL）をコード変更なしで両立させました。

- **Docker のマルチステージビルド**
  ビルド用と実行用のイメージを分離し、成果物の JAR だけを含む**軽量な実行イメージ**を作成。文字化け対策として UTF-8 のロケール設定も行いました。

- **運用を見据えた構造化ログ**
  `LogUtils` を用意し、処理時間・操作種別・件数などを **JSON 形式で一元的に出力**。ログ基盤への連携や障害調査を意識した設計です。

- **ヘルスチェックによる自己診断**
  Actuator の `/actuator/health` を Docker のヘルスチェックに組み込み、コンテナの死活監視を自動化しました。

- **例外を握りつぶさない設計**
  `TaskNotFoundException` などの独自例外と専用エラーページを用意し、想定外の入力にも安全に応答します。

---

## 📈 このプロジェクトで得たもの

はじめは書籍の内容を**意識的に写経することから始め、約 2 週間で基本形を完成**させました。
そこで満足せず、以下のように一歩ずつ機能を積み上げていきました。

1. 検索機能を **カテゴリ分類機能へ再設計**し、仕様から自分で考える経験を積んだ
2. **セキュリティ強化・構造化ログ**を導入し、動くだけでなく運用できるアプリへ
3. **Docker による本番環境構築**まで踏み込み、インフラ含めた全体像を掴んだ

「Spring Boot でアプリを一通り作れる」だけでなく、
**環境構築・ロギング・エラー設計・コンテナ化といった "その先" まで自走できる**ことを示すために作り込んだプロジェクトです。

---

## 📁 ディレクトリ構成（抜粋）

```
src/main/java/com/example/todo/
├── controller/      # 画面・リクエスト処理（task / category）
├── service/         # 業務ロジック
├── repository/      # データアクセス
├── entity/          # Task / Category エンティティ
└── util/            # 構造化ログ用ユーティリティ

src/main/resources/
├── templates/       # Thymeleaf テンプレート
├── schema.sql       # 開発用（H2）スキーマ
└── schema-prod.sql  # 本番用（MySQL）スキーマ

Dockerfile / docker-compose.yml   # 本番環境定義
```

---

<p align="center">
  <i>ご覧いただきありがとうございます。ご質問やフィードバックがあればお気軽にどうぞ。</i>
</p>
