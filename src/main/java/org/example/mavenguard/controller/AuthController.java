package org.example.mavenguard.controller;

import org.example.mavenguard.service.UserService;
import org.example.mavenguard.vo.UserVO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpSession;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    @Autowired
    private UserService userService;

    // 회원가입
    // AuthController.java

    @PostMapping("/register")
    public Map<String, Object> register(@RequestBody UserVO user) {
        Map<String, Object> result = new HashMap<>();

        // [가이드 준수] 백엔드 유효성 검증 (Validation)
        if (user.getEmail() == null || user.getEmail().trim().isEmpty() ||
                user.getNickname() == null || user.getNickname().trim().isEmpty() ||
                user.getPassword() == null || user.getPassword().trim().isEmpty()) {

            result.put("success", false);
            result.put("message", "모든 필드(이메일, 닉네임, 비밀번호)를 입력해야 합니다.");
            return result;
        }

        try {
            userService.register(user);
            result.put("success", true);
        } catch (Exception e) {
            e.printStackTrace();
            result.put("success", false);
            result.put("message", "회원가입 중 오류가 발생했습니다. (중복된 이메일 등)");
        }
        return result;
    }

    // 로그인
    @PostMapping("/login")
    public Map<String, Object> login(@RequestBody Map<String, String> body,
                                     HttpSession session) {

        UserVO user = userService.login(
                body.get("email"),
                body.get("password")
        );

        Map<String, Object> result = new HashMap<>();

        if (user == null) {
            result.put("success", false);
            result.put("message", "이메일 또는 비밀번호가 올바르지 않습니다.");
            return result;
        }

        session.setAttribute("loginUser", user);

        result.put("success", true);
        result.put("userId", user.getUserId());
        result.put("email", user.getEmail());
        return result;
    }

    // 로그아웃
    @PostMapping("/logout")
    public void logout(HttpSession session) {
        session.invalidate();
    }

    // 로그인 상태 확인
    @GetMapping("/me")
    public UserVO me(HttpSession session) {
        return (UserVO) session.getAttribute("loginUser");
    }
}

