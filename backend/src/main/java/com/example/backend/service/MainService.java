package com.example.backend.service;

import com.example.backend.dto.*;
import com.example.backend.repository.ImageDetailRepository;
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
    private final ImageDetailRepository imageDetailRepository;

    public FlowerItemReturnInfo flowerSetToTestDB(SaveRequestDto saveRequestDto) throws IOException {
        FlowersInfoDto flowersInfoDto = databaseService.flowerSetToTestDB(saveRequestDto);

        ImageDetailDto imageDetailDto = new ImageDetailDto();
        if (saveRequestDto.getFile() != null && !saveRequestDto.getFile().isEmpty()) {
            imageDetailDto.setCategory(saveRequestDto.getCategory());
            imageDetailDto.setName(flowersInfoDto != null ? flowersInfoDto.getName_jp() : saveRequestDto.getAnalyzeResponseDto().getName());
        }
        FlowerItemReturnInfo returnInfo = new FlowerItemReturnInfo();
        returnInfo.setUuid(flowersInfoDto.getUuid());
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
            imageDetailDto.setName(shrineInfoDto != null ? shrineInfoDto.getName() : saveRequestDto.getShrineAnalyzeResponceDto().getName());
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

    public boolean flowerSetToDB(String uuid){
        return databaseService.flowerSetToDB(uuid);
    }

    public List<ImageDetailDto> getImagesByCategoryAndUser(String category,String userIdStr){
        List<ImageDetailDto> dtoList = databaseService.getImagesByCategoryAndUser(category, userIdStr);

        return dtoList;
    }

    public List<ShrineInfoDto> getShrineInfo() {
        return databaseService.getShrineInfo();
    }
}