package com.example.backend.service;

import com.example.backend.dto.*;
import com.github.dozermapper.core.DozerBeanMapper;
import lombok.AllArgsConstructor;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.time.LocalDate;
import java.util.List;
import java.util.UUID; // UUIDのために追加

@Service
@AllArgsConstructor
public class MainService {

    private final DatabaseService databaseService;
    private final DozerBeanMapper mapper;

    public FlowerItemReturnInfo flowerSetToDB(SaveRequestDto saveRequestDto) throws IOException {
        FlowersInfoDto flowersInfoDto = databaseService.flowerSetToDB(saveRequestDto);

        ImageDetailDto imageDetailDto = new ImageDetailDto();
        if (saveRequestDto.getFile() != null && !saveRequestDto.getFile().isEmpty()) {
            imageDetailDto.setImageData(saveRequestDto.getFile().getBytes());
            imageDetailDto.setCategory(saveRequestDto.getCategory());
            imageDetailDto.setName(flowersInfoDto != null ? flowersInfoDto.getName_jp() : saveRequestDto.getAnalyzeResponseDto().getName());
            //imageDetailDto.setShootingDate(LocalDate.now());
        }
        FlowerItemReturnInfo returnInfo = new FlowerItemReturnInfo();
        returnInfo.setUuid(UUID.randomUUID().toString());
        returnInfo.setFlowersInfo(flowersInfoDto);
        imageDetailDto.setImageData(null);
        returnInfo.setImageDetail(imageDetailDto);
        returnInfo.setDate(LocalDate.now().toString());
        return returnInfo;
    }

    public ShrineItemReturnInfo shrineSetToDB(SaveRequestDto saveRequestDto) throws IOException {
        ShrineInfoDto shrineInfoDto = databaseService.ShrineSetToDB(saveRequestDto);
        ImageDetailDto imageDetailDto = new ImageDetailDto();
        if (saveRequestDto.getFile() != null && !saveRequestDto.getFile().isEmpty()) {
            imageDetailDto.setCategory(saveRequestDto.getCategory());
            imageDetailDto.setImageData(saveRequestDto.getFile().getBytes());
            imageDetailDto.setName(shrineInfoDto != null ? shrineInfoDto.getName() : saveRequestDto.getShrineAnalyzeResponceDto().getName());
           // imageDetailDto.setShootingDate(LocalDate.now());
        }
        ShrineItemReturnInfo returnInfo = new ShrineItemReturnInfo();
        returnInfo.setUuid(UUID.randomUUID().toString());
        returnInfo.setShrineInfo(shrineInfoDto);
        imageDetailDto.setImageData(null);
        returnInfo.setImageDetail(imageDetailDto);
        returnInfo.setDate(LocalDate.now().toString());

        return returnInfo;
    }

    public List<QuizDto> getAllQuiz() {
        return databaseService.getAllQuiz();
    }

    public ItemReturnInfo getPicturesById(Integer id) {
        return databaseService.getPicturesById(id);
    }
}