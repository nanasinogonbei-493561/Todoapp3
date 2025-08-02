package com.example.todo.controller.category;


import com.example.todo.entity.Category;
import com.example.todo.service.category.CategoryService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

@Controller
@RequiredArgsConstructor
@RequestMapping("/categories")
public class CategoryController {

    private final CategoryService categoryService;

    @GetMapping
    public String list(CategoryForm form, Model model) {
        /* var categoryList = categoryService.find()
                  .stream()
                  .map(CategoryDTO::toDTO)
                  .toList();
         */
        var categoryList = categoryService.findAll();
        model.addAttribute("categoryList", categoryList);
        return  "categories/list";
    }

    @GetMapping("/{id}")
    public String showDetail(@PathVariable("id") long searchId, Model model) {
        var categoryEntity = categoryService.findById(searchId).orElse(null);

        if (categoryEntity == null) {
            return  "rediret:/";
        }
        model.addAttribute("id", searchId);
        model.addAttribute("categoryEntity", categoryEntity);
        return "categories/detail";
    }

    @GetMapping("/creationForm")
    public String showCreationForm(@ModelAttribute CategoryForm form, Model model) {
       model.addAttribute("mode", "CREATE");
       return "categories/form";
    }

    @PostMapping("/{id}/editForm")
    public String create(@Validated CategoryForm form, BindingResult bindingResult, Model model) {
        if (bindingResult.hasErrors()) {
            return showCreationForm(form, model);
        }
        categoryService.create(form.toEntity());

        model.addAttribute("number", 100);

        return "redirect:/categories";
    }

    @GetMapping("/{id}/editForm")
    public String showEditForm(@PathVariable("id") long id, Model model) {
        Category categoryEntity = categoryService.findById(id).orElse(null);
        CategoryForm categoryForm = CategoryForm.fromEntity(categoryEntity);

        model.addAttribute("mode", "EDIT");
        model.addAttribute("categoryForm", categoryForm);
        return "categories/form";
    }

    @PutMapping("{id}")  // PUT /categories/ {is}
    public String update(
            @PathVariable("id") long id,
            @Validated @ModelAttribute CategoryForm form,
            BindingResult bindingResult,
            Model model
    ) {
        if (bindingResult.hasErrors()) {
            model.addAttribute("mode", "EDIT");
            return "categories/form";
        }

        Category entity = categoryService.findById(id).get();
        // var entitu = form.toEntity(id0;
        entity.setName(form.name());
        entity.setDescription(form.description());
        // entity.setCategory_id(form.category_id());

        categoryService.update(entity);

        return "redirect:/categories/{id}";
    }

//    POST /tasks/1 (hidden: _method: delete)
//    -> DELETE /tasks/1
    @DeleteMapping("{id}")
    public String delete(@PathVariable("id") long id) {
        categoryService.delete(id);
        return "redirect:/categories";
    }
}
