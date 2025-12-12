package org.example.mavenguard.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.example.mavenguard.vo.LibraryVO;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import java.util.ArrayList;
import java.util.List;

@Service
public class LibraryService {

    private final RestTemplate restTemplate = new RestTemplate();
    private final ObjectMapper objectMapper = new ObjectMapper();

    // Maven Central 검색 API 호출
    public List<LibraryVO> searchLibraries(String keyword) {
        String url = "https://search.maven.org/solrsearch/select?q=" + keyword + "&rows=10&wt=json";
        List<LibraryVO> resultList = new ArrayList<>();

        try {
            // 1. 외부 API 호출 (결과를 String으로 받음)
            String response = restTemplate.getForObject(url, String.class);

            // 2. JSON 파싱 (Jackson 라이브러리 사용)
            JsonNode root = objectMapper.readTree(response);
            JsonNode docs = root.path("response").path("docs");

            // 3. 결과 리스트 만들기
            for (JsonNode doc : docs) {
                LibraryVO vo = new LibraryVO();
                vo.setGroupId(doc.path("g").asText());
                vo.setArtifactId(doc.path("a").asText());
                vo.setLatestVersion(doc.path("latestVersion").asText());
                resultList.add(vo);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return resultList;
    }
}
