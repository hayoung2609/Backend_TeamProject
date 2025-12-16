package org.example.mavenguard.vo;

import lombok.Data;

@Data
public class KitItemVO {
    private Long itemId;
    private Long kitId;
    private String groupId;
    private String artifactId;
    private String version;
}

