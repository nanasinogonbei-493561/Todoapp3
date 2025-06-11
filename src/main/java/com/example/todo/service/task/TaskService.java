package com.example.todo.service.task;

import com.example.todo.entity.Task;
import com.example.todo.repository.task.TaskRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class TaskService {

    private final TaskRepository taskRepository;

//    検索（条件検索が必要なら　Specification　や　QueryDSL が必要）
    public List<Task> findAll() {
        return taskRepository.findAll();
    }

    public Optional<Task> findById(long taskId) {
        return taskRepository.findById(taskId);
    }

    @Transactional
    public Task create(Task newEntity) {
        return taskRepository.save(newEntity);
    }

    @Transactional
    public Task update(Task entity) {
//        通常は一度DBから主屋してから変更した方が安全
        if (!taskRepository.existsById(entity.getId())) {
            throw new IllegalArgumentException("Entity not found");
        }
        return taskRepository.save(entity);  // save は存在すれば　udate　として動作
    }

    @Transactional
    public void delete(long id) {
        taskRepository.deleteById(id);
    }
}
