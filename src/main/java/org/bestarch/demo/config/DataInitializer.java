package org.bestarch.demo.config;

import org.bestarch.demo.model.Product;
import org.bestarch.demo.repository.ProductRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.ApplicationRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.ThreadLocalRandom;

@Configuration
public class DataInitializer {

    private static final Logger log = LoggerFactory.getLogger(DataInitializer.class);

    private static final String[] CATEGORIES = {
            "Electronics", "Books", "Clothing", "Home & Kitchen", "Toys",
            "Sports", "Beauty", "Grocery", "Automotive", "Office"
    };

    private static final String[] ADJECTIVES = {
            "Premium", "Classic", "Modern", "Vintage", "Ergonomic",
            "Portable", "Compact", "Deluxe", "Eco-Friendly", "Smart"
    };

    private static final String[] NOUNS = {
            "Widget", "Gadget", "Notebook", "Backpack", "Lamp",
            "Headphones", "Bottle", "Charger", "Speaker", "Mug"
    };

    @Bean
    ApplicationRunner seedProducts(ProductRepository repository) {
        return args -> {
            long existing = repository.count();
            log.info("Clearing {} existing product(s) and seeding 100 new products", existing);
            repository.deleteAll();

            List<Product> seed = new ArrayList<>(100);
            ThreadLocalRandom rnd = ThreadLocalRandom.current();
            for (int i = 1; i <= 100; i++) {
                String adjective = ADJECTIVES[rnd.nextInt(ADJECTIVES.length)];
                String noun = NOUNS[rnd.nextInt(NOUNS.length)];
                String category = CATEGORIES[rnd.nextInt(CATEGORIES.length)];

                Product product = new Product();
                product.setName(adjective + " " + noun + " #" + i);
                product.setDescription("Auto-generated " + adjective.toLowerCase() + " " + noun.toLowerCase());
                product.setCategory(category);
                product.setSku(String.format("SKU-%05d", i));
                product.setPrice(BigDecimal.valueOf(rnd.nextDouble(5.0, 500.0))
                        .setScale(2, RoundingMode.HALF_UP));
                product.setQuantity(rnd.nextInt(1, 200));
                seed.add(product);
            }

            repository.saveAll(seed);
            log.info("Seeded {} products", seed.size());
        };
    }
}