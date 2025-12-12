package org.example.mavenguard.mapper;

import org.example.mavenguard.vo.KitItemVO;
import org.example.mavenguard.vo.KitVO;
import java.util.List;

public interface KitMapper {
    // 1. Kit 메인 정보 저장 (저장 후 PK인 kitId를 vo에 담아줌)
    void insertKit(KitVO kitVO);

    // 2. Kit 아이템(라이브러리들) 저장
    void insertKitItem(KitItemVO itemVO);

    // 3. 내 Kit 목록 조회
    List<KitVO> selectKitsByUserId(Long userId);

    // 4. 특정 Kit의 아이템들 조회
    List<KitItemVO> selectItemsByKitId(Long kitId);
}
