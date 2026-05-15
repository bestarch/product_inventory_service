package org.bestarch.demo.service;

import org.bestarch.demo.model.Product;
import org.bestarch.demo.repository.ProductRepository;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class ProductService {

    private final ProductRepository repository;

    public ProductService(ProductRepository repository) {
        this.repository = repository;
    }

    public List<Product> findAll() {
        return repository.findAll();
    }

    public Optional<Product> findById(String id) {
        return repository.findById(id);
    }

    public Product save(Product product) {
        return repository.save(product);
    }

    public void deleteById(String id) {
        repository.deleteById(id);
    }
}