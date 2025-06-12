package com.example.todo.controller.category;

import com.example.todo.entity.Category;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

import java.util.Collections;

public record CategoryForm(
        @NotBlank
        @Size(max = 256, message = "256文字以内で入力してください")
        String name,
        String description
) {
    public static com.example.todo.controller.category.CategoryForm fromEntity(Category categoryEntity) {
        return new com.example.todo.controller.category.CategoryForm(
                categoryEntity.getName(),
                categoryEntity.getDescription()
        );
    }

    public Category toEntity() {
        return new Category(name(), description(), Collections.emptyList());
    }
}
