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

    // 1. Maven Central 검색 API 호출
    public List<LibraryVO> searchLibraries(String keyword) {
        String url = "https://search.maven.org/solrsearch/select?q=" + keyword + "&rows=10&wt=json";
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
                resultList.add(vo);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return resultList;
    }

    // 2. [추가] 보안 취약점 진단 (OSV API)
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
                result.put("count", root.path("vulns").size());
                result.put("detail", root.path("vulns").get(0).path("summary").asText());
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

    // 3. [추가] POM XML 파싱
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
                    // 최신 버전 필드에 현재 버전을 담아 재사용 (VO 수정 없이 사용)
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