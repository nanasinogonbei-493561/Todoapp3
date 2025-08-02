package com.example.todo.service.category;


import com.example.todo.entity.Category;
import com.example.todo.repository.category.CategoryRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class CategoryService {

    private final CategoryRepository categoryRepository;

//    findSimple -> findAllを使って全件取得
    public List<Category> findAll() {
        return categoryRepository.findAll();  // JPAリポジトリのfindAllメソッド
    }

//    find -> 任意の条件で検索
    public List<Category> find() {
        return categoryRepository.findAll();  // 現在は全件取得（条件を追加する場合はクエリメソッドを仕様）
    }

//    findById -> JPAの標準メソッドを仕様
    public Optional<Category> findById(long categoryId) {
        return categoryRepository.findById(categoryId);  // JPAのfindByIdメソッド
    }

    @Transactional
    public void create(Category newEntity) {
        categoryRepository.save(newEntity);  // JPAのsaveメソッド（新規作成・更新）
    }

    @Transactional
    public void update(Category newEntity) {
        categoryRepository.save(newEntity);  // JPAのsaveメソッド（新規作成・更新）
    }

    @Transactional
    public void delete(long id) {
        categoryRepository.deleteById(id);
    }
}
