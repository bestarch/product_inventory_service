package org.bestarch.demo.controller;

import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ModelAttribute;

@ControllerAdvice
public class GlobalModelAttributes {

    private final String currentUser;

    public GlobalModelAttributes(String currentUser) {
        this.currentUser = currentUser;
    }

    @ModelAttribute("currentUser")
    public String currentUser() {
        return currentUser;
    }
}