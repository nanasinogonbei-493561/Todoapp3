package com.example.todo.controller.task;

import com.example.todo.entity.Category;
import com.example.todo.entity.Task;
import com.example.todo.service.category.CategoryService;
import com.example.todo.service.task.TaskService;
import com.example.todo.service.task.TaskStatus;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequiredArgsConstructor
@RequestMapping("/tasks")
public class TaskController {

    private final TaskService taskService;
    private final CategoryService categoryService;

    @GetMapping
    public String list(Model model) {
        var taskList = taskService.findAll()
                .stream()
                .map(TaskDTO::toDTO)
                .toList();
        model.addAttribute("taskList", taskList);
        System.out.println(taskList);
        return "tasks/list";
    }

    @GetMapping("/{id}")
    public String showDetail(@PathVariable("id") long taskId, Model model) {
        var taskDTO = taskService.findById(taskId)
                .map(TaskDTO::toDTO)
                .orElseThrow(TaskNotFoundException::new);
        model.addAttribute("task", taskDTO);
        return "tasks/detail";
    }

    @GetMapping("/creationForm")
    public String showCreationForm(@ModelAttribute TaskForm form, Model model) {
        System.out.println("creationForm");
        model.addAttribute("mode", "CREATE");
        /* var categoryList = categoryService.find()
                    .stream()
                    .map(CategoryDTO::toDTO)
                    .toList();
           model.addAttribute("categoryList", categoryList);
         */
        var categoryList = categoryService.findAll();
        model.addAttribute("categoryList", categoryList);
        return "tasks/form";
    }

    @PostMapping
    public String create(@Validated TaskForm form, BindingResult bindingResult, Model model) {
        if (bindingResult.hasErrors()) {
            return showCreationForm(form, model);
        }
        Category category = categoryService.findById(form.category_id()).get();

        Task task = new Task(category, form.summary(), form.description(), TaskStatus.valueOf(form.status()));

        taskService.create(task);
        return "redirect:/tasks";
    }

    @GetMapping("/{id}/editForm")
    public String showEditForm(@PathVariable("id") long id, Model model) {
        var form = taskService.findById(id)
                .map(TaskForm::fromEntity)
                .orElseThrow(TaskNotFoundException::new);

        var categoryList = categoryService.findAll();
        
        model.addAttribute("taskForm", form);
        model.addAttribute("mode", "EDIT");
        model.addAttribute("categoryList", categoryList);
        return "tasks/form";
    }

    @PutMapping("{id}") // PUT /tasks/{id}
    public String update(
            @PathVariable("id") long id,
            @Validated @ModelAttribute TaskForm form,
            BindingResult bindingResult,
            Model model
    ) {
        if (bindingResult.hasErrors()) {
            model.addAttribute("mode", "EDIT");
            return "tasks/form";
        }
        /*
        var entity = form.toEntity(id);
        taskService.update(entity);
        return "redirect:/tasks/{id}";
         */

        Task entity = taskService.findById(id).get();
        Category category = categoryService.findById(form.category_id()).get();
        // var entity = form.toEntity(id);
        entity.setDescription(form.description());
        entity.setSummary(form.summary());
        // entity.setCategory_id(form.category_id());
        entity.setStatus(TaskStatus.valueOf(form.status()));
        entity.setCategory(category);
        taskService.update(entity);
        return "redirect:/tasks/{id}";
    }

    // POST /tasks/1 (hidden: _method: delete)
    // -> DELETE /tasks/1
    @DeleteMapping("{id}")
    public String delete(@PathVariable("id") long id) {
        taskService.delete(id);
        return "redirect:/tasks";
    }
}
