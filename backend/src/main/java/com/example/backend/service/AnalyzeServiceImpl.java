package com.example.backend.service;

import com.example.backend.config.ValueConfig;
import com.example.backend.dto.AnalyzeResponseDto;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.AllArgsConstructor;
import lombok.NoArgsConstructor;
import lombok.RequiredArgsConstructor;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.core.io.ByteArrayResource;

import java.io.IOException;

@RequiredArgsConstructor
@Service
public class AnalyzeServiceImpl implements AnalyzeService {

    private final RestTemplate restTemplate;
    private final ValueConfig valueConfig;


    @Override
    public AnalyzeResponseDto analyzeImage(MultipartFile file, String category) {
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
            body.add("image", byteArrayResource);  // 'image' キーで画像を追加
            body.add("category", category);  // 'category' キーでカテゴリを追加

            // ヘッダーの設定
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.MULTIPART_FORM_DATA);

            // リクエストの作成
            HttpEntity<MultiValueMap<String, Object>> entity = new HttpEntity<>(body, headers);

            // POSTリクエストを送信
            ResponseEntity<String> response = restTemplate.exchange(pythonServerUrl, HttpMethod.POST, entity, String.class);

            // レスポンスを解析して DTO を返す
            return parseAnalyzeResponse(response.getBody());
        } catch (IOException e) {
            throw new RuntimeException("Error while processing the image", e);
        }
    }

    private AnalyzeResponseDto parseAnalyzeResponse(String responseBody) {
        // JSONを解析するためのObjectMapperインスタンス
        ObjectMapper objectMapper = new ObjectMapper();

        try {
            // JSON文字列をAnalyzeResponseDtoオブジェクトに変換
            AnalyzeResponseDto dto = objectMapper.readValue(responseBody, AnalyzeResponseDto.class);

            // 解析結果を返す
            return dto;
        } catch (JsonProcessingException e) {
            // JSONの解析中にエラーが発生した場合、RuntimeExceptionをスロー
            throw new RuntimeException("Error parsing response", e);
        }
    }

}