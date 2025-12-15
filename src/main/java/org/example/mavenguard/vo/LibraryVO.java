package org.example.mavenguard.vo;

import lombok.Data;

@Data
public class LibraryVO {
    private String groupId;
    private String artifactId;
    private String latestVersion;
    private long lastUpdated;

    private String packaging;
    private String description;

    private boolean isSafe;
    private int vulnerabilityCount;
    private String vulnerabilityMsg;
    private String fixedVersion;
    private String recommendation;
}