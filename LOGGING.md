# ログ設定ガイド

## 概要

このプロジェクトでは構造化ログ（JSON形式）を使用して、効率的なログ分析とエラー検索を可能にしています。

## ログ設定

### 開発環境
- **コンソール出力**: 人間が読みやすい形式
- **ファイル出力**: JSON形式（`logs/application.json`）
- **ログレベル**: INFO

### 本番環境
- **コンソール出力**: JSON形式
- **ファイル出力**: JSON形式（`logs/application.json`）
- **エラーログ**: 専用ファイル（`logs/error.json`）
- **ログレベル**: WARN

## ログ検索ツール

### 1. コマンドライン検索

```bash
# 基本的な使用方法
./scripts/search-logs.sh [検索キーワード]

# エラーログのみを検索
./scripts/search-logs.sh -e

# 今日のログのみを検索
./scripts/search-logs.sh -t

# 特定のファイルから検索
./scripts/search-logs.sh -f error.json Exception

# JSON形式で出力
./scripts/search-logs.sh -j ERROR
```

### 2. VSCodeでの検索

#### 推奨拡張機能
- **Log Output Colorizer**: ログの色分け表示
- **JSON Language Support**: JSONファイルの構文ハイライト
- **Thunder Client**: APIテスト用

#### 検索方法
1. `Ctrl+Shift+F` (または `Cmd+Shift+F`) で検索
2. ファイルパターン: `logs/*.json`
3. 正規表現を使用してJSONフィールドを検索

```regex
# エラーログを検索
"level":"ERROR"

# 特定の操作を検索
"operation":"list_tasks"

# 特定の時間範囲を検索
"@timestamp":"2025-08-02"
```

## ログ構造

### JSON形式のログ例
```json
{
  "@timestamp": "2025-08-02T10:30:15.123Z",
  "level": "INFO",
  "logger_name": "com.example.todo.controller.task.TaskController",
  "message": "Operation completed: Task list retrieval took 45ms",
  "operation": "list_tasks",
  "duration_ms": "45",
  "task_count": "5"
}
```

### エラーログ例
```json
{
  "@timestamp": "2025-08-02T10:30:15.123Z",
  "level": "ERROR",
  "logger_name": "com.example.todo.controller.task.TaskController",
  "message": "Failed to retrieve task list",
  "operation": "list_tasks",
  "stack_trace": "java.lang.RuntimeException: Database connection failed..."
}
```

## ログユーティリティ

### LogUtilsクラスの使用方法

```java
import com.example.todo.util.LogUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class ExampleController {
    private static final Logger logger = LoggerFactory.getLogger(ExampleController.class);
    
    public void exampleMethod() {
        // コンテキスト付きログ
        Map<String, String> context = new HashMap<>();
        context.put("user_id", "123");
        context.put("operation", "create_task");
        
        LogUtils.logWithContext(logger, LogUtils.LogLevel.INFO, "Task created successfully", context);
        
        // エラーログ
        try {
            // 何らかの処理
        } catch (Exception e) {
            LogUtils.logError(logger, "Failed to create task", e, context);
        }
        
        // パフォーマンスログ
        long startTime = System.currentTimeMillis();
        // 処理
        LogUtils.logPerformance(logger, "Task creation", System.currentTimeMillis() - startTime, context);
    }
}
```

## 無料のログ分析ツール

### 1. jq (JSONクエリツール)
```bash
# エラーログを抽出
cat logs/application.json | jq 'select(.level == "ERROR")'

# 特定の操作のパフォーマンスを分析
cat logs/application.json | jq 'select(.operation == "list_tasks") | .duration_ms'

# 統計情報を取得
cat logs/application.json | jq -s 'group_by(.level) | map({level: .[0].level, count: length})'
```

### 2. grep + jq の組み合わせ
```bash
# エラーメッセージを検索
grep -i "database" logs/application.json | jq -r '.message'

# 特定の時間範囲を検索
grep "2025-08-02" logs/application.json | jq 'select(.level == "ERROR")'
```

### 3. VSCodeでの高度な検索
```json
// settings.json に追加
{
    "search.exclude": {
        "**/target": true,
        "**/build": true,
        "**/.gradle": true
    },
    "files.exclude": {
        "**/target": true,
        "**/build": true,
        "**/.gradle": true,
        "**/logs": false
    }
}
```

## トラブルシューティング

### よくある問題

1. **ログファイルが作成されない**
   - `logs` ディレクトリが存在することを確認
   - アプリケーションの書き込み権限を確認

2. **JSON形式で出力されない**
   - `logstash-logback-encoder` の依存関係を確認
   - `logback-spring.xml` の設定を確認

3. **検索スクリプトが動作しない**
   - `jq` コマンドがインストールされていることを確認
   - スクリプトの実行権限を確認: `chmod +x scripts/search-logs.sh`

### ログローテーション

ログファイルは自動的にローテーションされます：
- 日次ローテーション
- 30日間の保持期間
- ファイル名: `application.YYYY-MM-DD.json`

## セキュリティ考慮事項

1. **ログファイルの権限設定**
   ```bash
   chmod 640 logs/*.json
   ```

2. **機密情報の除外**
   - パスワードやトークンはログに出力しない
   - 個人情報は適切にマスキング

3. **ログファイルの監視**
   - ディスク容量の監視
   - ログファイルサイズの監視 