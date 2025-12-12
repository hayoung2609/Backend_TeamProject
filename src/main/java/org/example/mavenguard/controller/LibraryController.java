package org.example.mavenguard.controller;

import org.example.mavenguard.vo.LibraryVO;
import org.example.mavenguard.service.LibraryService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/libraries")
public class LibraryController {

    @Autowired
    private LibraryService libraryService;

    // 검색 API: GET /api/libraries/search?q=spring
    @GetMapping("/search")
    public List<LibraryVO> search(@RequestParam String q) {
        return libraryService.searchLibraries(q);
    }
}