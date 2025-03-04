package data.smartdeals_service.services.articleService;

import data.smartdeals_service.dto.article.ArticleGenerationRequest;
import data.smartdeals_service.dto.article.ArticleGenerationResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class ArticleService {

    private final RestTemplate restTemplate;

    @Value("${gemini.api.url}")
    private String geminiApiUrl;

    @Value("${gemini.api.key}")
    private String geminiApiKey;

    public ArticleService(RestTemplate restTemplate) {
        this.restTemplate = restTemplate;
    }

    public ArticleGenerationResponse generateArticle(ArticleGenerationRequest request) {
        try {
            // Prepare the request for Gemini
            Map<String, Object> geminiRequest = prepareGeminiRequest(request);

            // Set headers
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            headers.set("x-goog-api-key", geminiApiKey);

            HttpEntity<Map<String, Object>> entity = new HttpEntity<>(geminiRequest, headers);

            // Call Gemini API
            Map<String, Object> response = restTemplate.postForObject(geminiApiUrl, entity, Map.class);

            // Process response
            String generatedContent = extractContentFromGeminiResponse(response);

            // Create response
            ArticleGenerationResponse result = new ArticleGenerationResponse();
            result.setContent(generatedContent);
            result.setStatus("success");

            // Calculate metrics
            return calculateMetrics(result);

        } catch (Exception e) {
            ArticleGenerationResponse errorResponse = new ArticleGenerationResponse();
            errorResponse.setStatus("error");
            errorResponse.setMessage("Error generating article: " + e.getMessage());
            return errorResponse;
        }
    }

    public ArticleGenerationResponse calculateMetrics(ArticleGenerationResponse article) {
        String content = article.getContent();

        if (content == null || content.isEmpty()) {
            article.setWordCount(0);
            article.setCharacterCount(0);
            article.setReadingTimeMinutes(0.0);
            return article;
        }

        // Calculate word count
        String[] words = content.split("\\s+");
        int wordCount = words.length;

        // Calculate character count
        int characterCount = content.length();

        // Estimate reading time (average reading speed: 200 words per minute)
        double readingTimeMinutes = (double) wordCount / 200;

        article.setWordCount(wordCount);
        article.setCharacterCount(characterCount);
        article.setReadingTimeMinutes(readingTimeMinutes);

        return article;
    }

    private Map<String, Object> prepareGeminiRequest(ArticleGenerationRequest request) {
        Map<String, Object> geminiRequest = new HashMap<>();

        // Format the prompt based on the request parameters
        String prompt = formatPrompt(request);

        // Set up the request structure based on Gemini API requirements
        Map<String, Object> contents = new HashMap<>();
        Map<String, String> parts = new HashMap<>();
        parts.put("text", prompt);
        contents.put("parts", new Object[]{parts});

        geminiRequest.put("contents", new Object[]{contents});

        Map<String, Object> generationConfig = new HashMap<>();
        generationConfig.put("temperature", 0.7);
        generationConfig.put("maxOutputTokens", 8192);

        geminiRequest.put("generationConfig", generationConfig);

        return geminiRequest;
    }

    private String formatPrompt(ArticleGenerationRequest request) {
        StringBuilder prompt = new StringBuilder();
        prompt.append("Write an article about ").append(request.getTopic());

        if (request.getLanguage() != null && !request.getLanguage().isEmpty()) {
            prompt.append(" in ").append(request.getLanguage()).append(" language");
        }

        if (request.getMinWords() != null && request.getMaxWords() != null) {
            prompt.append(". The article should be between ")
                    .append(request.getMinWords())
                    .append(" and ")
                    .append(request.getMaxWords())
                    .append(" words");
        } else if (request.getMinWords() != null) {
            prompt.append(". The article should be at least ")
                    .append(request.getMinWords())
                    .append(" words");
        } else if (request.getMaxWords() != null) {
            prompt.append(". The article should be at most ")
                    .append(request.getMaxWords())
                    .append(" words");
        }

        if (request.getTone() != null && !request.getTone().isEmpty()) {
            prompt.append(". Use a ").append(request.getTone()).append(" tone");
        }

        if (request.getAdditionalInstructions() != null && !request.getAdditionalInstructions().isEmpty()) {
            prompt.append(". ").append(request.getAdditionalInstructions());
        }

        return prompt.toString();
    }

    private String extractContentFromGeminiResponse(Map<String, Object> response) {
        try {
            System.out.println("Response structure: " + response);

            if (response.containsKey("candidates")) {
                // Xử lý cả trường hợp candidates là ArrayList hoặc Array
                Object candidatesObj = response.get("candidates");
                List<Map<String, Object>> candidates;

                if (candidatesObj instanceof List) {
                    // Nếu candidates là ArrayList
                    candidates = (List<Map<String, Object>>) candidatesObj;
                } else if (candidatesObj instanceof Object[]) {
                    // Nếu candidates là Array
                    candidates = Arrays.asList((Map<String, Object>[]) candidatesObj);
                } else {
                    return "Unexpected type for candidates: " + candidatesObj.getClass().getName();
                }

                if (!candidates.isEmpty()) {
                    Map<String, Object> candidate = candidates.get(0);
                    if (candidate.containsKey("content")) {
                        Object contentObj = candidate.get("content");
                        Map<String, Object> content;

                        if (contentObj instanceof Map) {
                            content = (Map<String, Object>) contentObj;

                            if (content.containsKey("parts")) {
                                Object partsObj = content.get("parts");
                                List<Map<String, Object>> parts;

                                if (partsObj instanceof List) {
                                    // Nếu parts là ArrayList
                                    parts = (List<Map<String, Object>>) partsObj;
                                } else if (partsObj instanceof Object[]) {
                                    // Nếu parts là Array
                                    parts = Arrays.asList((Map<String, Object>[]) partsObj);
                                } else {
                                    return "Unexpected type for parts: " + partsObj.getClass().getName();
                                }

                                if (!parts.isEmpty()) {
                                    Map<String, Object> part = parts.get(0);
                                    if (part.containsKey("text")) {
                                        return (String) part.get("text");
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // Debugging: Xuất cấu trúc response chi tiết nếu không tìm thấy text
            return "Failed to extract content from response. Structure doesn't match expected format.";
        } catch (Exception e) {
            e.printStackTrace();
            return "Error parsing Gemini response: " + e.getMessage();
        }
    }
}