package com.example.todo.controller.task;

import com.example.todo.entity.Task;
import com.example.todo.service.task.TaskStatus;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

public record TaskForm(
        @NotNull
        Long category_id,
        @NotBlank
        @Size(max = 256, message = "256文字以内で入力してください")
        String summary,
        String description,
        @NotBlank
        @Pattern(regexp="TODO|DOING|DONE", message = "Todo, Doing, Done のいずれかを選択してください")
        String status
) {
    public static TaskForm fromEntity(Task task) {
        return new TaskForm(
                task.getCategory().getId(),
                task.getSummary(),
                task.getDescription(),
                task.getStatus().name()
        );
    }

    /*
    public TaskEntity toEntity() {
        return new TaskEntity(null, summary(), description(), TaskStatus.valueOf(status()));
    }


    public TaskEntity toEntity(long id) {
        return new TaskEntity(id, summary(), description(), TaskStatus.valueOf(status()));
    }
    
     */
}
