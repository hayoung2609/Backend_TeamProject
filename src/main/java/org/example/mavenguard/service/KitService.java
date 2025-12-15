package org.example.mavenguard.service;

import org.example.mavenguard.mapper.KitMapper;
import org.example.mavenguard.vo.KitItemVO;
import org.example.mavenguard.vo.KitVO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class KitService {

    @Autowired
    private KitMapper kitMapper;

    /**
     * ================================
     * 1️⃣ Kit 생성 (트랜잭션)
     * ================================
     */
    @Transactional
    public void createKit(KitVO kitVO) {

        // 1. kit 테이블 저장 (PK 생성됨)
        kitMapper.insertKit(kitVO);

        // 2. kit_item 테이블 저장
        if (kitVO.getItemList() != null) {
            for (KitItemVO item : kitVO.getItemList()) {
                item.setKitId(kitVO.getKitId());
                kitMapper.insertKitItem(item);
            }
        }
    }

    /**
     * ================================
     * 2️⃣ 내 Kit 목록 조회
     * ================================
     */
    public List<KitVO> getMyKits(Long userId) {
        return kitMapper.selectKitsByUserId(userId);
    }

    public KitVO getKit(Long kitId) {
        return kitMapper.selectKitById(kitId);
    }
    /**
     * ================================
     * 3️⃣ 내 Kit인지 검증 (보안 핵심)
     * ================================
     */
    public boolean isMyKit(Long userId, Long kitId) {
        return kitMapper.countMyKit(userId, kitId) > 0;
    }

    /**
     * ================================
     * 4️⃣ Kit에 포함된 라이브러리 목록
     * ================================
     */
    public List<KitItemVO> getItems(Long kitId) {
        return kitMapper.selectItemsByKitId(kitId);
    }
    /**
     * ================================
     * 5️⃣ Kit 수정
     * ================================
     */
    public void updateKit(KitVO kitVO) {
        // 내 Kit인지 확인 로직은 Controller 또는 여기서 수행
        kitMapper.updateKit(kitVO);
    }

    /**
     * ================================
     * 6️⃣ Kit 삭제 (트랜잭션: 아이템 삭제 -> Kit 삭제)
     * ================================
     */
    @Transactional
    public void deleteKit(Long kitId, Long userId) {
        // 1. 종속된 아이템 먼저 삭제
        kitMapper.deleteKitItems(kitId);
        // 2. 메인 Kit 삭제
        kitMapper.deleteKit(kitId, userId);
    }
}


