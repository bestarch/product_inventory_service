package org.bestarch.demo.repository;

import org.bestarch.demo.model.Product;
import org.springframework.data.mongodb.repository.MongoRepository;

public interface ProductRepository extends MongoRepository<Product, String> {
}