package com.example.backend.controller;

import com.example.backend.dto.*;
import com.example.backend.service.AnalyzeService;
import com.example.backend.service.DatabaseService;
import com.example.backend.service.LogService;
import com.example.backend.service.MainService;
import lombok.AllArgsConstructor;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.List;

@RestController
@AllArgsConstructor
public class MainController {

    private final AnalyzeService analyzeService;
    private final MainService mainService;
    private final LogService logService;
    private final DatabaseService databaseService;

    @PostMapping(value = "/analyze", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public Object analyze(@RequestPart("image") MultipartFile file,
                                  @RequestParam("category") String category,
                                  @RequestParam("userId") String userIdStr,
                                  @RequestParam("latitude") String latitude,// 緯度
                                  @RequestParam("longitude")String longitude) throws IOException {
        Integer userId = Integer.valueOf(userIdStr);
        System.out.println(" ");
        System.out.println("----接続完了----------------");
        SaveRequestDto saveRequestDto = new SaveRequestDto();
        saveRequestDto.setCategory(category);
        saveRequestDto.setUserId(userId);
        saveRequestDto.setFile(file);
        if (category.equals("flower")) {
            var DTO = analyzeService.getFlowerAnalysis(file,latitude,longitude);
            saveRequestDto.setAnalyzeResponseDto(DTO);
            FlowersInfoDto info = mainService.flowerSetToDB(saveRequestDto);
            logService.dtoLog((AnalyzeResponseDto) DTO);
            logService.infoLog(info);
            System.out.println(info);
            return info;
        }
        if (category.equals("shrine")) {
            var DTO = analyzeService.getShrineAnalysis(file,latitude,longitude);
            saveRequestDto.setShrineAnalyzeResponceDto(DTO);
            ShrineInfoDto info = mainService.shrineSetToDB(saveRequestDto);
            if(info != null) {
                logService.shrineLog(info);
            }
            return info;
        }
        return null;
    }

    @PostMapping(value = "/allPictures")
    public List<ImageDetailDto> returnPictures(@RequestParam("userId") String userIdStr,
                               @RequestParam("category") String category) {
        System.out.println(" ");
        System.out.println("----接続完了----------------");
        Integer userId = Integer.valueOf(userIdStr);
        List<ImageDetailDto> imageDetailDto= databaseService.getImagesByCategoryAndUser(category,userId);
        logService.imageDetailListLog(imageDetailDto);
        return imageDetailDto;
    }

    @GetMapping("/")
    public String index() {
        System.out.println("接続完了:Hello");
        return "hello";
    }
}
