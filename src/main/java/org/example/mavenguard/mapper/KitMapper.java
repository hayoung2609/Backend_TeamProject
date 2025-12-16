package org.example.mavenguard.mapper;

import org.example.mavenguard.vo.KitItemVO;
import org.example.mavenguard.vo.KitVO;
import org.apache.ibatis.annotations.Param;
import java.util.List;

public interface KitMapper {

    // 1. Kit 저장
    void insertKit(KitVO kitVO);
    void insertKitItem(KitItemVO itemVO);

    // 2. 조회
    List<KitVO> selectKitsByUserId(Long userId);
    List<KitItemVO> selectItemsByKitId(Long kitId);

    // 상세 조회 (이전 단계에서 추가했던 것)
    KitVO selectKitById(Long kitId);

    // 3. 검증
    int countMyKit(@Param("userId") Long userId, @Param("kitId") Long kitId);

    // 4. 수정/삭제
    void updateKit(KitVO kitVO);
    void deleteKit(@Param("kitId") Long kitId, @Param("userId") Long userId);
    void deleteKitItems(Long kitId);

    // [추가] 전체 Kit 조회 (관리자용 - 모든 사용자의 Kit)
    List<KitVO> selectAllKitsAdmin();

    // [추가] Kit 강제 삭제 (관리자용 - 소유자 확인 없이)
    void deleteKitByAdmin(Long kitId);
}