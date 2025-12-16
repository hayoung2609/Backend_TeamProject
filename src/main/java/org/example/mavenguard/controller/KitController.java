package org.example.mavenguard.controller;

import org.example.mavenguard.service.KitService;
import org.example.mavenguard.vo.KitItemVO;
import org.example.mavenguard.vo.KitVO;
import org.example.mavenguard.vo.UserVO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpSession;
import java.util.List;

@Controller
@RequestMapping("/kits")
public class KitController {

    @Autowired
    private KitService kitService;

    /**
     * ================================
     * 1️⃣ Kit 생성 (AJAX 저장)
     * ================================
     */
    @PostMapping
    @ResponseBody
    public String createKit(@RequestBody KitVO kitVO,
                            HttpSession session) {

        UserVO loginUser = (UserVO) session.getAttribute("loginUser");
        if (loginUser == null) {
            return "LOGIN_REQUIRED";
        }

        // 🔒 userId는 반드시 서버에서 주입
        kitVO.setUserId(loginUser.getUserId());

        kitService.createKit(kitVO);
        return "OK";
    }

    /**
     * ================================
     * 2️⃣ 나만의 Kit 목록 페이지
     * URL : /kits/my
     * ================================
     */
    @GetMapping("/my")
    public String myKitPage(HttpSession session,
                            Model model) {

        UserVO loginUser = (UserVO) session.getAttribute("loginUser");
        if (loginUser == null) {
            return "redirect:/login.jsp";
        }

        List<KitVO> myKits = kitService.getMyKits(loginUser.getUserId());
        model.addAttribute("kitList", myKits);

        // 👉 /WEB-INF/views/my_kit.jsp
        return "my_kit";
    }

    /**
     * ================================
     * 3️⃣ Kit 상세 조회 (AJAX)
     * URL : /kits/{kitId}
     * ================================
     */
    @GetMapping("/{kitId}")
    @ResponseBody
    public KitVO getKitDetail(@PathVariable Long kitId, HttpSession session) {
        UserVO loginUser = (UserVO) session.getAttribute("loginUser");
        if (loginUser == null) return null;

        // 1. 내 Kit인지 검증
        if (!kitService.isMyKit(loginUser.getUserId(), kitId)) {
            return null;
        }

        // [수정됨] 2. Kit 기본 정보 조회 (제목, 설명 등)
        KitVO kit = kitService.getKit(kitId);

        // 3. 아이템(라이브러리) 목록 조회 및 설정
        List<KitItemVO> items = kitService.getItems(kitId);
        kit.setItemList(items);

        return kit;
    }

    /**
     * ================================
     * 4️⃣ Kit 수정 (AJAX)
     * ================================
     */
    @PutMapping("/{kitId}")
    @ResponseBody
    public String updateKit(@PathVariable Long kitId,
                            @RequestBody KitVO kitVO,
                            HttpSession session) {
        UserVO loginUser = (UserVO) session.getAttribute("loginUser");
        if (loginUser == null) return "LOGIN_REQUIRED";

        // 본인 확인
        if (!kitService.isMyKit(loginUser.getUserId(), kitId)) {
            return "PERMISSION_DENIED";
        }

        kitVO.setKitId(kitId);
        kitVO.setUserId(loginUser.getUserId());
        kitService.updateKit(kitVO);
        return "OK";
    }

    /**
     * ================================
     * 5️⃣ Kit 삭제 (AJAX)
     * ================================
     */
    @DeleteMapping("/{kitId}")
    @ResponseBody
    public String deleteKit(@PathVariable Long kitId, HttpSession session) {
        UserVO loginUser = (UserVO) session.getAttribute("loginUser");
        if (loginUser == null) return "LOGIN_REQUIRED";

        if (!kitService.isMyKit(loginUser.getUserId(), kitId)) {
            return "PERMISSION_DENIED";
        }

        kitService.deleteKit(kitId, loginUser.getUserId());
        return "OK";
    }
}

