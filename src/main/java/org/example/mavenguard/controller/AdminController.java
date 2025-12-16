package org.example.mavenguard.controller;

import org.example.mavenguard.service.KitService;
import org.example.mavenguard.service.UserService;
import org.example.mavenguard.vo.KitVO;
import org.example.mavenguard.vo.UserVO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpSession;
import java.util.List;

@Controller
@RequestMapping("/admin")
public class AdminController {

    @Autowired private UserService userService;
    @Autowired private KitService kitService;

    // 대시보드 (회원 목록 + Kit 목록)
    @GetMapping("/dashboard")
    public String dashboard(HttpSession session, Model model) {
        UserVO user = (UserVO) session.getAttribute("loginUser");
        if (user == null || !"ROLE_ADMIN".equals(user.getRole())) {
            return "redirect:/"; // 권한 없으면 메인으로
        }

        // 1. 전체 회원 조회
        List<UserVO> userList = userService.getAllUsers();
        model.addAttribute("users", userList);

        // 2. 전체 Kit 조회 (관리 기능용)
        List<KitVO> kitList = kitService.getAllKitsForAdmin();
        model.addAttribute("kits", kitList);

        return "admin_dashboard";
    }

    // --- 회원 관리 Actions ---

    @PostMapping("/users/{userId}/delete")
    @ResponseBody
    public String deleteUser(@PathVariable Long userId) {
        userService.deleteUser(userId);
        return "OK";
    }

    @PostMapping("/users/{userId}/role")
    @ResponseBody
    public String toggleRole(@PathVariable Long userId, @RequestParam String role) {
        userService.updateUserRole(userId, role);
        return "OK";
    }

    // --- Kit 관리 Actions ---

    @PostMapping("/kits/{kitId}/delete")
    @ResponseBody
    public String deleteKit(@PathVariable Long kitId) {
        kitService.deleteKitByAdmin(kitId);
        return "OK";
    }
}