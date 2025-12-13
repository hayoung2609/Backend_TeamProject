package org.example.mavenguard.controller;

import org.example.mavenguard.vo.LibraryVO;
import org.example.mavenguard.service.LibraryService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/libraries")
public class LibraryController {

    @Autowired
    private LibraryService libraryService;

    // 1. 라이브러리 검색 API
    @GetMapping("/search")
    public List<LibraryVO> search(@RequestParam String q) {
        return libraryService.searchLibraries(q);
    }

    // 2. [추가] 보안 취약점 진단 API
    @PostMapping("/check")
    public Map<String, Object> checkSecurity(@RequestBody Map<String, String> params) {
        return libraryService.checkVulnerability(
                params.get("groupId"),
                params.get("artifactId"),
                params.get("version")
        );
    }

    // 3. [추가] POM XML 파싱 API
    @PostMapping("/parse")
    public List<LibraryVO> parsePom(@RequestBody String xmlText) {
        return libraryService.parsePomXml(xmlText);
    }
}