package org.example.mavenguard.vo;

import lombok.Data;
import java.util.Date;
import java.util.List;

@Data
public class KitVO {
    private Long kitId;
    private Long userId;

    private String title;
    private String projectVersion;
    private String category;
    private String description;
    private boolean isPublic;

    private Date createdAt;
    private Date updatedAt;

    private List<KitItemVO> itemList;
}