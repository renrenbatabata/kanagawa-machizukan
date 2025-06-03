package com.example.backend.dto;

import lombok.Data;
import org.springframework.web.multipart.MultipartFile;

@Data
public class SaveRequestDto {
    private AnalyzeResponseDto analyzeResponseDto;
    private ShrineAnalyzeResponceDto shrineAnalyzeResponceDto;
    private String category;
    private Integer userId;
    private MultipartFile file;
}
