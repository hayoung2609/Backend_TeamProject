package org.example.mavenguard.service;

import org.example.mavenguard.mapper.UserMapper;
import org.example.mavenguard.vo.UserVO;
import org.mindrot.jbcrypt.BCrypt; // Import 추가
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class UserService {

    @Autowired
    private UserMapper userMapper;

    // 회원가입
    public void register(UserVO user) {
        // BCrypt로 비밀번호 암호화 (Salt 자동 생성)
        String hashedPassword = BCrypt.hashpw(user.getPassword(), BCrypt.gensalt());
        user.setPassword(hashedPassword);

        userMapper.insertUser(user);
    }

    // 로그인
    public UserVO login(String email, String password) {
        UserVO user = userMapper.selectByEmail(email);
        if (user == null) return null;

        // BCrypt 비밀번호 검증 (입력받은 비번 vs DB 암호화된 비번)
        if (!BCrypt.checkpw(password, user.getPassword())) {
            return null; // 비번 불일치
        }

        return user; // 로그인 성공
    }

    List<UserVO> getAllUsers(){
        return userMapper.selectAllUsers();
    }
}