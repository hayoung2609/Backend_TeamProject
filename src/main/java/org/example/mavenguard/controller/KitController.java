package org.example.mavenguard.controller;

import org.example.mavenguard.vo.KitVO;
import org.example.mavenguard.service.KitService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/kits")
public class KitController {

    @Autowired
    private KitService kitService;

    // Kit 저장 API
    @PostMapping
    public String createKit(@RequestBody KitVO kitVO) {
        // 임시: 로그인 기능 구현 전이므로 userId가 없으면 1로 고정
        if (kitVO.getUserId() == null) {
            kitVO.setUserId(1L);
        }

        kitService.createKit(kitVO);
        return "success: Kit ID = " + kitVO.getKitId();
    }

    // 내 Kit 목록 조회 API
    @GetMapping("/my")
    public List<KitVO> getMyKits(@RequestParam(defaultValue = "1") Long userId) {
        return kitService.getMyKits(userId);
    }
}