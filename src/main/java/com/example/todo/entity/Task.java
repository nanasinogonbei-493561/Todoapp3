package com.example.todo.entity;

import com.example.todo.service.task.TaskStatus;
import lombok.ToString;
import jakarta.persistence.*;
import lombok.Data;

import org.springframework.boot.autoconfigure.web.WebProperties;

@Data
@Entity
@Table(name = "tasks")
public class Task {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "category_id")
    @ToString.Exclude
    private Category category;

    @Column(name = "summary")
    private String summary;

    @Column(name = "description")
    private String description;

    @Column(name = "status")
    @Enumerated(EnumType.STRING)
    private TaskStatus status;

    public  Task() {
    }

    public Task(Category category, String summary, String description, TaskStatus taskStatus) {
       this.id = id;
       this.category = category;
       this.summary = summary;
       this.description = description;
       this.status = taskStatus;
    }
}
