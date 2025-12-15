package org.example.mavenguard.vo;

import lombok.Data;

@Data
public class LibraryVO {
    private String groupId;
    private String artifactId;
    private String latestVersion;
    private long lastUpdated;
}