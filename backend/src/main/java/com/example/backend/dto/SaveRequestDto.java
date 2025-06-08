package com.example.backend.dto;

import lombok.Data;
import org.springframework.web.multipart.MultipartFile;

@Data
public class SaveRequestDto {
    private AnalyzeResponseDto analyzeResponseDto;
    private ShrineAnalyzeResponceDto shrineAnalyzeResponceDto;
    private String category;
    private String userId;
    private MultipartFile file;
}
