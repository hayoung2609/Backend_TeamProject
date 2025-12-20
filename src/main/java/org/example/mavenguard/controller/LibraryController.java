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

    // 1. 검색
    @GetMapping("/search")
    public List<LibraryVO> search(@RequestParam String q) {
        return libraryService.searchLibraries(q);
    }

    // 2. 보안 진단 (단건 - 사용자가 버전 수정 후 호출)
    @PostMapping("/check")
    public Map<String, Object> checkSecurity(@RequestBody Map<String, String> params) {
        return libraryService.checkVulnerability(
                params.get("groupId"),
                params.get("artifactId"),
                params.get("version")
        );
    }

    // 3. POM 파싱 및 일괄 진단 (수정됨)
    @PostMapping("/parse")
    public List<LibraryVO> parsePom(@RequestBody String xmlText) {
        // 기존 parsePomXml 대신 진단 로직이 포함된 diagnosePom 호출
        return libraryService.diagnosePom(xmlText);
    }
}