package org.example.mavenguard.vo;

import lombok.Data;
import java.util.Date;
import java.util.List;

@Data // Lombok이 Getter/Setter/ToString 자동 생성
public class KitVO {
    private Long kitId;
    private Long userId;
    private String title;
    private String description;
    private boolean isPublic;
    private Date createdAt;

    // Kit 저장할 때 같이 들어오는 라이브러리 리스트
    private List<KitItemVO> itemList;
}