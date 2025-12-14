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
}
