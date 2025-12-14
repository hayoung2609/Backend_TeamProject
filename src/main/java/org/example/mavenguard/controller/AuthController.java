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
    @PostMapping("/register")
    public Map<String, Object> register(@RequestBody UserVO user) {
        userService.register(user);

        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
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

