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

    /**
     * 1. Maven Central 검색
     * - 검색은 빨라야 하므로 보안 진단(외부 API 호출)은 제외하고 메타데이터만 구성합니다.
     */
    public List<LibraryVO> searchLibraries(String keyword) {
        String url = "https://search.maven.org/solrsearch/select?q=" + keyword + "&rows=20&wt=json";
        List<LibraryVO> resultList = new ArrayList<>();

        try {
            String response = restTemplate.getForObject(url, String.class);
            JsonNode root = objectMapper.readTree(response);
            JsonNode docs = root.path("response").path("docs");

            for (JsonNode doc : docs) {
                LibraryVO vo = new LibraryVO();
                String g = doc.path("g").asText();
                String a = doc.path("a").asText();
                String v = doc.path("latestVersion").asText();
                String p = doc.path("p").asText(); // packaging

                vo.setGroupId(g);
                vo.setArtifactId(a);
                vo.setLatestVersion(v);
                vo.setLastUpdated(doc.path("timestamp").asLong());
                vo.setPackaging(p);

                // 사용자가 보기 편한 설명 포맷 생성
                vo.setDescription(String.format("[%s] %s:%s", p, g, a));

                resultList.add(vo);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return resultList;
    }

    /**
     * 2. POM 파일 진단 (파싱 + 일괄 보안 검사)
     * - 사용자가 붙여넣은 XML 내용을 파싱 후, 각 라이브러리마다 보안 검사를 수행합니다.
     */
    public List<LibraryVO> diagnosePom(String xmlText) {
        // 1. 파싱
        List<LibraryVO> dependencies = parsePomXml(xmlText);

        // 2. 보안 진단 (사용자가 버전을 수정할 수 있으므로, 입력된 버전 그대로 진단)
        for (LibraryVO vo : dependencies) {
            // 버전이 변수(${...})가 아니고 실제 값일 때만 진단
            if (vo.getLatestVersion() != null && !vo.getLatestVersion().startsWith("${")) {
                fillSecurityData(vo);
            } else {
                vo.setSafe(true);
                vo.setVulnerabilityMsg("버전 정보 확인 불가 (변수 사용 등)");
            }
        }
        return dependencies;
    }

    /**
     * 3. 단건 보안 진단 (사용자가 버전을 수정했을 때 호출됨)
     */
    public Map<String, Object> checkVulnerability(String groupId, String artifactId, String version) {
        LibraryVO vo = new LibraryVO();
        vo.setGroupId(groupId);
        vo.setArtifactId(artifactId);
        vo.setLatestVersion(version);

        // 공통 진단 로직 호출
        fillSecurityData(vo);

        // Controller 반환용 Map 구성
        Map<String, Object> result = new HashMap<>();
        result.put("safe", vo.isSafe());
        result.put("count", vo.getVulnerabilityCount());
        result.put("detail", vo.getVulnerabilityMsg());
        result.put("fixedVersion", vo.getFixedVersion());
        result.put("recommendation", vo.getRecommendation());

        return result;
    }

    /**
     * [핵심] OSV API를 이용해 데이터를 채우는 공통 메서드
     */
    private void fillSecurityData(LibraryVO vo) {
        String url = "https://api.osv.dev/v1/query";

        Map<String, Object> requestBody = new HashMap<>();
        requestBody.put("version", vo.getLatestVersion()); // 사용자가 입력/수정한 버전 기준
        Map<String, String> packageInfo = new HashMap<>();
        packageInfo.put("name", vo.getGroupId() + ":" + vo.getArtifactId());
        packageInfo.put("ecosystem", "Maven");
        requestBody.put("package", packageInfo);

        try {
            String response = restTemplate.postForObject(url, requestBody, String.class);
            JsonNode root = objectMapper.readTree(response);

            if (root.has("vulns")) {
                vo.setSafe(false);
                JsonNode vulns = root.path("vulns");
                vo.setVulnerabilityCount(vulns.size());

                String summary = vulns.get(0).path("summary").asText();
                if (summary == null || summary.isEmpty()) summary = "취약점 상세 정보 없음";
                vo.setVulnerabilityMsg(summary);

                // 해결된 버전(Fixed Version) 찾기
                String fixedVersion = findFixedVersion(vulns.get(0));
                vo.setFixedVersion(fixedVersion);

                vo.setRecommendation(fixedVersion.equals("정보 없음") ?
                        "최신 버전으로 업데이트를 권장합니다." :
                        fixedVersion + " 버전 이상으로 업데이트하세요.");
            } else {
                vo.setSafe(true);
                vo.setVulnerabilityCount(0);
                vo.setVulnerabilityMsg("발견된 취약점이 없습니다.");
                vo.setRecommendation("현재 버전을 사용해도 좋습니다.");
            }
        } catch (Exception e) {
            vo.setSafe(false);
            vo.setVulnerabilityMsg("진단 서버 연결 실패");
        }
    }

    private String findFixedVersion(JsonNode vulnNode) {
        try {
            JsonNode affected = vulnNode.path("affected").get(0);
            JsonNode ranges = affected.path("ranges").get(0);
            for (JsonNode event : ranges.path("events")) {
                if (event.has("fixed")) {
                    return event.path("fixed").asText();
                }
            }
        } catch (Exception ignore) {}
        return "정보 없음";
    }

    // 기존 POM 파싱 로직 (그대로 유지)
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
        try {
            NodeList nodeList = element.getElementsByTagName(tag);
            if (nodeList.getLength() > 0) {
                return nodeList.item(0).getTextContent();
            }
        } catch (Exception e) { return ""; }
        return "";
    }
}