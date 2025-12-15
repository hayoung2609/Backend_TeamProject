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
        // q=keyword & core=gav (기본)
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
                String p = doc.path("p").asText(); // packaging (jar, pom, war...)

                vo.setGroupId(g);
                vo.setArtifactId(a);
                vo.setLatestVersion(v);
                vo.setLastUpdated(doc.path("timestamp").asLong());
                vo.setPackaging(p);

                // [수정됨] 태그 정보 파싱 (사용자에게 어떤 라이브러리인지 힌트 제공)
                List<String> tags = new ArrayList<>();
                if (doc.has("tags")) {
                    for (JsonNode tag : doc.path("tags")) {
                        tags.add(tag.asText());
                    }
                }

                // 설명 필드에 패키징과 태그 정보를 조합하여 저장
                StringBuilder desc = new StringBuilder();
                desc.append("[").append(p.toUpperCase()).append("] ");
                if (!tags.isEmpty()) {
                    desc.append("Tags: ").append(String.join(", ", tags));
                } else {
                    desc.append(g);
                }
                vo.setDescription(desc.toString());

                resultList.add(vo);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return resultList;
    }

    public List<LibraryVO> diagnosePom(String xmlText) {
        List<LibraryVO> dependencies = parsePomXml(xmlText);
        for (LibraryVO vo : dependencies) {
            if (vo.getLatestVersion() != null && !vo.getLatestVersion().startsWith("${")) {
                fillSecurityData(vo);
            } else {
                vo.setSafe(true);
                vo.setVulnerabilityMsg("버전 정보 확인 불가 (변수 사용 등)");
            }
        }
        return dependencies;
    }

    public Map<String, Object> checkVulnerability(String groupId, String artifactId, String version) {
        LibraryVO vo = new LibraryVO();
        vo.setGroupId(groupId);
        vo.setArtifactId(artifactId);
        vo.setLatestVersion(version);

        fillSecurityData(vo);

        Map<String, Object> result = new HashMap<>();
        result.put("safe", vo.isSafe());
        result.put("count", vo.getVulnerabilityCount());
        result.put("detail", vo.getVulnerabilityMsg());
        result.put("fixedVersion", vo.getFixedVersion());
        result.put("recommendation", vo.getRecommendation());

        return result;
    }

    private void fillSecurityData(LibraryVO vo) {
        String url = "https://api.osv.dev/v1/query";

        Map<String, Object> requestBody = new HashMap<>();
        requestBody.put("version", vo.getLatestVersion());
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
        } catch (Exception ignore) {
        }
        return "정보 없음";
    }

    public List<LibraryVO> parsePomXml(String xmlText) {
        List<LibraryVO> list = new ArrayList<>();
        try {
            DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
            DocumentBuilder builder = factory.newDocumentBuilder();
            // XML 파싱
            Document doc = builder.parse(new InputSource(new StringReader(xmlText)));
            doc.getDocumentElement().normalize();

            Map<String, String> propertiesMap = new HashMap<>();
            NodeList propsList = doc.getElementsByTagName("properties");
            if (propsList.getLength() > 0) {
                Node propsNode = propsList.item(0);
                NodeList childNodes = propsNode.getChildNodes();
                for (int i = 0; i < childNodes.getLength(); i++) {
                    Node item = childNodes.item(i);
                    if (item.getNodeType() == Node.ELEMENT_NODE) {
                        propertiesMap.put(item.getNodeName(), item.getTextContent());
                    }
                }
            }

            NodeList nList = doc.getElementsByTagName("dependency");

            for (int i = 0; i < nList.getLength(); i++) {
                Node node = nList.item(i);
                if (node.getNodeType() == Node.ELEMENT_NODE) {
                    Element element = (Element) node;
                    LibraryVO vo = new LibraryVO();

                    vo.setGroupId(getTagValue("groupId", element));
                    vo.setArtifactId(getTagValue("artifactId", element));

                    // 버전 가져오기
                    String rawVersion = getTagValue("version", element);

                    // 3. 버전이 ${...} 형태라면 propertiesMap에서 찾아 치환
                    String resolvedVersion = resolveVersion(rawVersion, propertiesMap);

                    vo.setLatestVersion(resolvedVersion);
                    list.add(vo);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * ${variable} 형태의 버전을 실제 값으로 변환하는 헬퍼 메서드
     */
    private String resolveVersion(String rawVersion, Map<String, String> props) {
        if (rawVersion == null || rawVersion.isEmpty()) return "Unknown";

        // ${...} 패턴인지 확인
        if (rawVersion.startsWith("${") && rawVersion.endsWith("}")) {
            // ${spring.version} -> spring.version 추출
            String key = rawVersion.substring(2, rawVersion.length() - 1);

            // 맵에 해당 키가 있으면 값 반환, 없으면 원본 그대로 반환
            return props.getOrDefault(key, rawVersion);
        }

        // 변수가 아니면 그대로 반환
        return rawVersion;
    }

    private String getTagValue(String tag, Element element) {
        try {
            NodeList nodeList = element.getElementsByTagName(tag);
            if (nodeList.getLength() > 0) {
                return nodeList.item(0).getTextContent();
            }
        } catch (Exception e) {
            return "";
        }
        return "";
    }
}