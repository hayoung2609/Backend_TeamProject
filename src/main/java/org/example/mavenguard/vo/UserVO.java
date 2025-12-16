package org.example.mavenguard.vo;

import lombok.Data;
import java.util.Date;

@Data
public class UserVO {
    private Long userId;
    private String email;
    private String password;
    private String nickname;
    private String role;
    private Date createdAt;
}