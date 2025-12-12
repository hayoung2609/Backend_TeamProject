package org.example.mavenguard.service;

import org.example.mavenguard.vo.KitItemVO;
import org.example.mavenguard.vo.KitVO;
import org.example.mavenguard.mapper.KitMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class KitService {

    @Autowired
    private KitMapper kitMapper;

    // 트랜잭션: Kit 저장과 아이템 저장이 모두 성공해야 함 (하나라도 실패하면 롤백)
    @Transactional
    public void createKit(KitVO kitVO) {
        // 1. Kit 정보 저장 (여기서 kitId가 생성됨)
        kitMapper.insertKit(kitVO);

        // 2. 아이템들 반복해서 저장
        if (kitVO.getItemList() != null) {
            for (KitItemVO item : kitVO.getItemList()) {
                item.setKitId(kitVO.getKitId()); // 생성된 키트 ID 주입
                kitMapper.insertKitItem(item);
            }
        }
    }

    public List<KitVO> getMyKits(Long userId) {
        return kitMapper.selectKitsByUserId(userId);
    }
}