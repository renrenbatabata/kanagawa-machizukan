package com.example.backend.dto;

import lombok.Data;
import org.springframework.web.multipart.MultipartFile;

@Data
public class SaveRequestDto {
    private AnalyzeResponseDto dto;
    private String category;
    private Integer userId;
    private MultipartFile file;
}
