package org.example.mavenguard.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class HomeController {

    @GetMapping("/")
    public String home() {
        return "index";
    }

    @GetMapping("/login")
    public String loginPage() {
        return "login";
    }

    // 2. 회원가입 페이지 매핑 ( /register 접속 시 register.jsp 보여줌 )
    @GetMapping("/register")
    public String registerPage() {
        return "register";
    }
}