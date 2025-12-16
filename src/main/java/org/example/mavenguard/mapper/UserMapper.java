package org.example.mavenguard.mapper;

import org.apache.ibatis.annotations.Param;
import org.example.mavenguard.vo.UserVO;
import java.util.List;

public interface UserMapper {

    // 회원가입
    void insertUser(UserVO user);

    // 로그인용 조회
    UserVO selectByEmail(String email);

    // 전체 회원 조회 (관리자용)
    List<UserVO> selectAllUsers();

    // [추가] 회원 권한 변경 (관리자용)
    void updateUserRole(@Param("userId") Long userId, @Param("role") String role);

    // [추가] 회원 강제 탈퇴 (관리자용)
    void deleteUser(Long userId);
}