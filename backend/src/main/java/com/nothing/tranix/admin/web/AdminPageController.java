package com.nothing.tranix.admin.web;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

/** The simple admin website (static page, signs in with an admin mobile + OTP and calls /api/v1/admin/**). */
@Controller
class AdminPageController {

    @GetMapping({"/admin", "/admin/"})
    String page() {
        return "redirect:/admin/index.html";
    }
}
