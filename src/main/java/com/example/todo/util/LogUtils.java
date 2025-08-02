package com.example.todo.util;

import java.util.Map;
import org.slf4j.Logger;
import org.slf4j.MDC;

/**
 * 構造化ログを簡単に出力するためのユーティリティクラス
 */
public class LogUtils {
    
    /**
     * ログにコンテキスト情報を追加して出力
     * 
     * @param logger ロガー
     * @param level ログレベル
     * @param message メッセージ
     * @param context コンテキスト情報
     */
    public static void logWithContext(Logger logger, LogLevel level, String message, Map<String, String> context) {
        try {
            // MDCにコンテキスト情報を設定
            if (context != null) {
                context.forEach(MDC::put);
            }
            
            // ログレベルに応じて出力
            switch (level) {
                case DEBUG -> logger.debug(message);
                case INFO -> logger.info(message);
                case WARN -> logger.warn(message);
                case ERROR -> logger.error(message);
            }
        } finally {
            // MDCをクリア
            MDC.clear();
        }
    }
    
    /**
     * エラーログを構造化して出力
     * 
     * @param logger ロガー
     * @param message メッセージ
     * @param throwable 例外
     * @param context コンテキスト情報
     */
    public static void logError(Logger logger, String message, Throwable throwable, Map<String, String> context) {
        try {
            if (context != null) {
                context.forEach(MDC::put);
            }
            logger.error(message, throwable);
        } finally {
            MDC.clear();
        }
    }
    
    /**
     * パフォーマンスログを出力
     * 
     * @param logger ロガー
     * @param operation 操作名
     * @param durationMs 実行時間（ミリ秒）
     * @param context コンテキスト情報
     */
    public static void logPerformance(Logger logger, String operation, long durationMs, Map<String, String> context) {
        try {
            if (context != null) {
                context.forEach(MDC::put);
            }
            MDC.put("operation", operation);
            MDC.put("duration_ms", String.valueOf(durationMs));
            
            if (durationMs > 1000) {
                logger.warn("Slow operation detected: {} took {}ms", operation, durationMs);
            } else {
                logger.info("Operation completed: {} took {}ms", operation, durationMs);
            }
        } finally {
            MDC.clear();
        }
    }
    
    /**
     * ログレベル列挙型
     */
    public enum LogLevel {
        DEBUG, INFO, WARN, ERROR
    }
} 