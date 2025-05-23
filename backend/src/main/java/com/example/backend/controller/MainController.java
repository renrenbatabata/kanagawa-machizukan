package com.example.backend.controller;

import com.example.backend.dto.FlowersInfoDto;
import com.example.backend.dto.SaveRequestDto;
import com.example.backend.service.AnalyzeService;
import com.example.backend.service.LogService;
import com.example.backend.service.MainService;
import lombok.AllArgsConstructor;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;

@RestController
@AllArgsConstructor
public class MainController {

    private final AnalyzeService analyzeService;
    private final MainService mainService;
    private final LogService logService;

    @PostMapping(value = "/analyze", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public FlowersInfoDto analyze(@RequestPart("image") MultipartFile file,
                                  @RequestParam("category") String category,
                                  @RequestParam("userId") String userIdstr,
                                  @RequestParam("latitude") String latitude,// 緯度
                                  @RequestParam("longitude")String longitude) throws IOException {
        Integer userId = Integer.valueOf(userIdstr);
        System.out.println(" ");
        System.out.println("----接続完了----------------");
        var DTO = analyzeService.analyzeImage(file, category);
        SaveRequestDto saveRequestDto = new SaveRequestDto();
        saveRequestDto.setCategory(category);
        saveRequestDto.setUserId(userId);
        saveRequestDto.setDto(DTO);
        saveRequestDto.setFile(file);
        FlowersInfoDto info = mainService.setDB(saveRequestDto);
        logService.dtoLog(DTO);
        logService.infoLog(info);
        System.out.println(info);
        return info;
    }

    @PostMapping(value = "/pictures")
    public void returnPictures() {

    }

    @GetMapping("/")
    public String index() {
        System.out.println("接続完了:Hello");
        return "hello";
    }
}
