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
     * 1️⃣ Kit 생성 (index.jsp → 저장)
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

        // 세션에서 userId 주입 (보안상 필수)
        kitVO.setUserId(loginUser.getUserId());

        kitService.createKit(kitVO);
        return "OK";
    }

    /**
     * ================================
     * 2️⃣ 나만의 Kit 목록 페이지
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

        return "my_kit"; // my_kit.jsp
    }

    /**
     * ================================
     * 3️⃣ Kit 상세 조회 (AJAX)
     * ================================
     */
    @GetMapping("/{kitId}")
    @ResponseBody
    public KitVO getKitDetail(@PathVariable Long kitId,
                              HttpSession session) {

        UserVO loginUser = (UserVO) session.getAttribute("loginUser");
        if (loginUser == null) {
            return null;
        }

        // 내 Kit인지 검증 (보안 핵심)
        if (!kitService.isMyKit(loginUser.getUserId(), kitId)) {
            return null;
        }

        List<KitItemVO> items = kitService.getItems(kitId);

        KitVO kit = new KitVO();
        kit.setKitId(kitId);
        kit.setItemList(items);

        return kit;
    }
}
