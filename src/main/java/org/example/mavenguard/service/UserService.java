package org.example.mavenguard.service;

import org.example.mavenguard.mapper.UserMapper;
import org.example.mavenguard.vo.UserVO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.security.MessageDigest;

@Service
public class UserService {

    @Autowired
    private UserMapper userMapper;

    // 회원가입
    public void register(UserVO user) {
        user.setPassword(sha256(user.getPassword()));
        userMapper.insertUser(user);
    }

    // 로그인
    public UserVO login(String email, String password) {
        UserVO user = userMapper.selectByEmail(email);
        if (user == null) return null;

        String encrypted = sha256(password);
        if (!encrypted.equals(user.getPassword())) return null;

        return user;
    }

    // SHA-256 암호화
    private String sha256(String input) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] hash = md.digest(input.getBytes("UTF-8"));
            StringBuilder sb = new StringBuilder();
            for (byte b : hash) {
                sb.append(String.format("%02x", b));
            }
            return sb.toString();
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }
}
