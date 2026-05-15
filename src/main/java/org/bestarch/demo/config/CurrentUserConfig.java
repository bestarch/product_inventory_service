package org.bestarch.demo.config;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.nio.file.Files;
import java.nio.file.Path;

@Configuration
public class CurrentUserConfig {

    private static final Logger log = LoggerFactory.getLogger(CurrentUserConfig.class);
    private static final Path USER_FILE = Path.of("myuser.txt");
    private static final String FALLBACK = "Guest";

    @Bean
    public String currentUser() {
        if (!Files.exists(USER_FILE)) {
            log.warn("User file '{}' not found; defaulting to '{}'", USER_FILE.toAbsolutePath(), FALLBACK);
            return FALLBACK;
        }
        try {
            return Files.readAllLines(USER_FILE).stream()
                    .map(String::trim)
                    .filter(s -> !s.isEmpty())
                    .findFirst()
                    .orElse(FALLBACK);
        } catch (Exception e) {
            log.warn("Failed to read '{}': {}", USER_FILE.toAbsolutePath(), e.getMessage());
            return FALLBACK;
        }
    }
}