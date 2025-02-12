package fpt.aptech.fitnessgoalservice.service;


import lombok.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestTemplate;
import org.springframework.http.HttpHeaders;


@Component
public class GoogleApiClient {
    private final RestTemplate restTemplate = new RestTemplate();

    //Gửi yêu cầu tới API Google và nhận chế độ ăn
    public String getDietPlanFromGoogle(String content) {
        String apiUrl = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=AIzaSyCltshmEO8ByUZYJe6n1lfAtfB3DmQnfUc";

        //Gửi yêu cầu POST đến Google API
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);

        //Tạo body yêu cầu
        String requestBody = "{\"contents\": [{\"parts\": [{\"text\": \"" + content + "\"}]}]}";

        HttpEntity<String> entity = new HttpEntity<>(requestBody, headers);
        ResponseEntity<String> responseEntity = restTemplate.postForEntity(apiUrl, entity, String.class);
        return responseEntity.getBody(); //Trả về dữ liệu phản hồi từ API Google
    }

}
