package com.example.backend.service;

import com.example.backend.config.ValueConfig;
import com.example.backend.dto.AnalyzeResponseDto;
import com.example.backend.dto.ShrineAnalyzeResponceDto;
import com.example.backend.repository.FlowersRepository;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.core.io.ByteArrayResource;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.List;

//import static jdk.internal.org.jline.reader.impl.LineReaderImpl.CompletionType.List;

@RequiredArgsConstructor
@Service
public class AnalyzeServiceImpl implements AnalyzeService {

    private final RestTemplate restTemplate;
    private final ValueConfig valueConfig;
    private final ObjectMapper objectMapper;
    private final FlowersRepository flowersRepository;

    @Override
    public String analyzeImage(MultipartFile file, String category, String latitude, String longitude) {
        String pythonServerUrl = valueConfig.getPythonUrl();
        try {
            // 画像ファイルを ByteArrayResource に変換
            ByteArrayResource byteArrayResource = new ByteArrayResource(file.getBytes()) {
                @Override
                public String getFilename() {
                    return file.getOriginalFilename();
                }
            };

            // リクエスト作成
            MultiValueMap<String, Object> body = new LinkedMultiValueMap<>();
            body.add("image", byteArrayResource);
            body.add("category", category);
            body.add("latitude", latitude);
            body.add("longitude", longitude);
            if (category.equals("flower")) {
                List<String> flowersList = flowersRepository.getAllNameEn();
                body.add("flowersList",flowersList);
            }

            // ヘッダーの設定
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.MULTIPART_FORM_DATA);

            // リクエストの作成
            HttpEntity<MultiValueMap<String, Object>> entity = new HttpEntity<>(body, headers);

            // POSTリクエストを送信
            ResponseEntity<String> response = restTemplate.exchange(pythonServerUrl, HttpMethod.POST, entity, String.class);

            return response.getBody();

        } catch (IOException e) {
            throw new RuntimeException("Error while processing the image", e);
        }
    }

    @Override
    public AnalyzeResponseDto getFlowerAnalysis(MultipartFile file, String latitude, String longitude) {
        String responseBody = analyzeImage(file, "flower", latitude, longitude);
        //return objectMapper.readValue(responseBody, AnalyzeResponseDto.class);
        var dto = new AnalyzeResponseDto();
        dto.setName_en(responseBody);
        return dto;
    }

    @Override
    public ShrineAnalyzeResponceDto getShrineAnalysis(MultipartFile file, String latitude, String longitude) {
        String responseBody = analyzeImage(file, "shrine", latitude, longitude);
        try {
            return objectMapper.readValue(responseBody, ShrineAnalyzeResponceDto.class);
        } catch (JsonProcessingException e) {
            throw new RuntimeException("Error parsing response as ShrineAnalyzeResponceDto", e);
        }
    }
}