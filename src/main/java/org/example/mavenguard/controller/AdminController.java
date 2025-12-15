package org.example.mavenguard.controller;

import org.example.mavenguard.service.UserService;
import org.example.mavenguard.vo.UserVO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import javax.servlet.http.HttpSession;
import java.util.List;

@Controller
@RequestMapping("/admin")
public class AdminController {

    @Autowired
    private UserService userService; // 유저 목록 조회를 위해 UserMapper에 메서드 추가 필요

    @GetMapping("/dashboard")
    public String dashboard(HttpSession session, Model model) {
        UserVO user = (UserVO) session.getAttribute("loginUser");

        // 1. 로그인 및 권한 체크
        if (user == null || !"ROLE_ADMIN".equals(user.getRole())) {
            return "redirect:/index.jsp?error=unauthorized";
        }

        // 2. 전체 회원 목록 조회 (UserMapper에 selectAllUsers 추가 필요)
        // List<UserVO> userList = userService.getAllUsers();
        // model.addAttribute("users", userList);

        return "admin_dashboard"; // /WEB-INF/views/admin_dashboard.jsp
    }
}