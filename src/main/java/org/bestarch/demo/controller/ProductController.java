package org.bestarch.demo.controller;

import jakarta.validation.Valid;
import org.bestarch.demo.model.Product;
import org.bestarch.demo.service.ProductService;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

@Controller
@RequestMapping("/products")
public class ProductController {

    private final ProductService service;

    public ProductController(ProductService service) {
        this.service = service;
    }

    @GetMapping
    public String list(Model model) {
        model.addAttribute("products", service.findAll());
        return "list";
    }

    @GetMapping("/new")
    public String newProductForm(Model model) {
        model.addAttribute("product", new Product());
        model.addAttribute("mode", "new");
        return "form";
    }

    @PostMapping
    public String create(@Valid @ModelAttribute("product") Product product,
                         BindingResult result,
                         RedirectAttributes redirectAttributes) {
        if (result.hasErrors()) {
            return "form";
        }
        service.save(product);
        redirectAttributes.addFlashAttribute("flash", "Product created");
        return "redirect:/products";
    }

    @GetMapping("/{id}/edit")
    public String editForm(@PathVariable String id, Model model, RedirectAttributes redirectAttributes) {
        return service.findById(id)
                .map(product -> {
                    model.addAttribute("product", product);
                    model.addAttribute("mode", "edit");
                    return "form";
                })
                .orElseGet(() -> {
                    redirectAttributes.addFlashAttribute("flash", "Product not found");
                    return "redirect:/products";
                });
    }

    @PostMapping("/{id}")
    public String update(@PathVariable String id,
                         @Valid @ModelAttribute("product") Product product,
                         BindingResult result,
                         RedirectAttributes redirectAttributes,
                         Model model) {
        if (result.hasErrors()) {
            model.addAttribute("mode", "edit");
            return "form";
        }
        product.setId(id);
        service.save(product);
        redirectAttributes.addFlashAttribute("flash", "Product updated");
        return "redirect:/products";
    }

    @PostMapping("/{id}/delete")
    public String delete(@PathVariable String id, RedirectAttributes redirectAttributes) {
        service.deleteById(id);
        redirectAttributes.addFlashAttribute("flash", "Product deleted");
        return "redirect:/products";
    }
}