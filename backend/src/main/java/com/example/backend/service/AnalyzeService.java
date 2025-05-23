package com.example.backend.service;

import com.example.backend.dto.AnalyzeResponseDto;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import reactor.core.publisher.Mono;

@Service
public interface AnalyzeService {
    AnalyzeResponseDto analyzeImage(MultipartFile image, String category);
}
