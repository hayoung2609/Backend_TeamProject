package org.example.mavenguard.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.example.mavenguard.vo.LibraryVO;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.xml.sax.InputSource;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import java.io.StringReader;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class LibraryService {

    private final RestTemplate restTemplate = new RestTemplate();
    private final ObjectMapper objectMapper = new ObjectMapper();

    // 1. Maven Central 검색 (날짜 정보 추가)
    public List<LibraryVO> searchLibraries(String keyword) {
        // core='gav' 옵션을 추가하면 더 정확한 그룹/아티팩트 검색이 가능하지만, 일단 기본 검색 사용
        String url = "https://search.maven.org/solrsearch/select?q=" + keyword + "&rows=20&wt=json";
        List<LibraryVO> resultList = new ArrayList<>();

        try {
            String response = restTemplate.getForObject(url, String.class);
            JsonNode root = objectMapper.readTree(response);
            JsonNode docs = root.path("response").path("docs");

            for (JsonNode doc : docs) {
                LibraryVO vo = new LibraryVO();
                vo.setGroupId(doc.path("g").asText());
                vo.setArtifactId(doc.path("a").asText());
                vo.setLatestVersion(doc.path("latestVersion").asText());

                // [추가] 마지막 업데이트 타임스탬프 (유지보수 여부 판단용)
                vo.setLastUpdated(doc.path("timestamp").asLong());

                resultList.add(vo);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return resultList;
    }

    // 2. 보안 취약점 진단 (OSV API 고도화)
    public Map<String, Object> checkVulnerability(String groupId, String artifactId, String version) {
        String url = "https://api.osv.dev/v1/query";
        Map<String, Object> result = new HashMap<>();

        Map<String, Object> requestBody = new HashMap<>();
        requestBody.put("version", version);
        Map<String, String> packageInfo = new HashMap<>();
        packageInfo.put("name", groupId + ":" + artifactId);
        packageInfo.put("ecosystem", "Maven");
        requestBody.put("package", packageInfo);

        try {
            String response = restTemplate.postForObject(url, requestBody, String.class);
            JsonNode root = objectMapper.readTree(response);

            if (root.has("vulns")) {
                result.put("safe", false);
                JsonNode vulns = root.path("vulns");
                result.put("count", vulns.size());

                // 첫 번째 취약점의 상세 정보 추출
                JsonNode firstVuln = vulns.get(0);
                result.put("detail", firstVuln.path("summary").asText());

                // [추가] 해결된 버전(Fixed Version) 찾기
                String fixedVersion = "정보 없음";
                try {
                    // affected -> ranges -> events -> fixed 구조 탐색
                    JsonNode affected = firstVuln.path("affected").get(0);
                    JsonNode ranges = affected.path("ranges").get(0);
                    for (JsonNode event : ranges.path("events")) {
                        if (event.has("fixed")) {
                            fixedVersion = event.path("fixed").asText();
                            break;
                        }
                    }
                } catch (Exception ignore) {}

                result.put("fixedVersion", fixedVersion);
                result.put("recommendation", fixedVersion.equals("정보 없음") ?
                        "최신 버전으로 업데이트를 권장합니다." :
                        fixedVersion + " 버전 이상으로 업데이트하세요.");

            } else {
                result.put("safe", true);
                result.put("message", "발견된 취약점이 없습니다.");
            }
        } catch (Exception e) {
            e.printStackTrace();
            result.put("error", "진단 중 오류 발생");
        }
        return result;
    }

    // 3. POM 파싱 (기존 유지)
    public List<LibraryVO> parsePomXml(String xmlText) {
        List<LibraryVO> list = new ArrayList<>();
        try {
            DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
            DocumentBuilder builder = factory.newDocumentBuilder();
            Document doc = builder.parse(new InputSource(new StringReader(xmlText)));
            doc.getDocumentElement().normalize();

            NodeList nList = doc.getElementsByTagName("dependency");

            for (int i = 0; i < nList.getLength(); i++) {
                Node node = nList.item(i);
                if (node.getNodeType() == Node.ELEMENT_NODE) {
                    Element element = (Element) node;
                    LibraryVO vo = new LibraryVO();
                    vo.setGroupId(getTagValue("groupId", element));
                    vo.setArtifactId(getTagValue("artifactId", element));
                    vo.setLatestVersion(getTagValue("version", element));
                    list.add(vo);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    private String getTagValue(String tag, Element element) {
        NodeList nodeList = element.getElementsByTagName(tag).item(0).getChildNodes();
        Node node = (Node) nodeList.item(0);
        return node != null ? node.getNodeValue() : "";
    }
}