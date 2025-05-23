package com.example.backend.service;

import com.example.backend.dto.AnalyzeResponseDto;
import com.example.backend.dto.FlowersInfoDto;
import org.springframework.stereotype.Service;

@Service
public class LogService {
    public void dtoLog(AnalyzeResponseDto dto){
        System.out.println("name:" + dto.getName());
        System.out.println("CommonNames:" + dto.getCommonNames());
        System.out.println("Description:" + dto.getDescription());
        System.out.println("taxonomy:" + dto.getTaxonomy());
    }

    public void infoLog(FlowersInfoDto info) {
        System.out.println("name_jp:" + info.getName_jp());
        System.out.println("name_en:" + info.getName_en());
        System.out.println("meaning:" + info.getMeaning());
        System.out.println("属:" + info.getGenius());
        System.out.println("科:" + info.getFamily());
        System.out.println("解説:" + info.getDescription());
    }
}
