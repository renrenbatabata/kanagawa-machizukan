package com.example.backend.service;

import com.example.backend.dto.AnalyzeResponseDto;
import com.example.backend.dto.FlowersInfoDto;
import com.example.backend.dto.ImageDetailDto;
import com.example.backend.dto.ShrineInfoDto;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.List;

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
    public void imageDetailListLog(List<ImageDetailDto> dto){
        for (ImageDetailDto imageDetailDto : dto) {
            System.out.println("=============================================");
            System.out.println("Name:" + imageDetailDto.getName());
            System.out.println("Category:" + imageDetailDto.getCategory());
            System.out.println("ShootingDate:" + imageDetailDto.getShootingDate());
            System.out.println("ImageData:" + imageDetailDto.getImageData());
        }
    }
    public void imageDetailLog(ImageDetailDto dto){
            System.out.println("=============================================");
            System.out.println("Name:" + dto.getName());
            System.out.println("Category:" + dto.getCategory());


    }

    public void shrineLog(ShrineInfoDto info){
        System.out.println("name:" + info.getName());
        System.out.println("hiragana:" + info.getHiragana());
        System.out.println("hint:" + info.getHint());
        System.out.println("feature:" + info.getFeatures());
        System.out.println("error" + info.getError());
    }

    public void connectLog(String connectName) {
        LocalDateTime time = LocalDateTime.now();
        System.out.println(" ");
        System.out.println("----" + time + "----接続完了:" + connectName + "----------------");
    }
}
