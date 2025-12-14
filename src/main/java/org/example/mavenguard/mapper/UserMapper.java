package org.example.mavenguard.mapper;

import org.example.mavenguard.vo.UserVO;

public interface UserMapper {

    // 회원가입
    void insertUser(UserVO user);

    // 로그인용 조회
    UserVO selectByEmail(String email);
}
