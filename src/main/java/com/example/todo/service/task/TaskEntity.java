package com.example.todo.service.task;


public record TaskEntity(
        Long id,
        String summary,
        String description,
        TaskStatus status,
        Long categoryId
) {

//     既存のコードとの互換性のためのファクトリメソッド
    public static TaskEntity of(Long id, String summary, String description, TaskStatus status){
        return new TaskEntity(id, summary, description, status, null);
    }
}
