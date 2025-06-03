package com.example.backend.service;

import com.example.backend.dto.AnalyzeResponseDto;
import com.example.backend.dto.ShrineAnalyzeResponceDto;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import reactor.core.publisher.Mono;

@Service
public interface AnalyzeService {
    //String analyzeImageInternal(MultipartFile file, String category, String latitude, String longitude) ;

    String analyzeImage(MultipartFile file, String category, String latitude, String longitude);

    AnalyzeResponseDto getFlowerAnalysis(MultipartFile file, String latitude, String longitude);

    ShrineAnalyzeResponceDto getShrineAnalysis(MultipartFile file, String latitude, String longitude);
}
