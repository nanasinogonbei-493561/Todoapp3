package com.example.todo.controller.category;

import com.example.todo.entity.Category;

public record CategoryDTO(long id,
                          String name,
                          String description

) {
    public static CategoryDTO toDTO(Category entity) {
        return new CategoryDTO(
                entity.getId(),
                entity.getName(),
                entity.getDescription()
        );
    }
}
