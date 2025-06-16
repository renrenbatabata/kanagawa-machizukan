package com.example.backend.service;

import com.example.backend.dto.*;
import com.example.backend.dto.top.CountInfo;
import com.example.backend.dto.top.FlowerCountInfo;
import com.example.backend.dto.top.ShrineCountInfo;
import com.example.backend.dto.top.TopInfoDto;
import com.example.backend.repository.ImageDetailRepository;
import com.example.backend.repository.TempDetailsRepository;
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
    private final TempDetailsRepository tempDetailsRepository;


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
        returnInfo.setUuid(shrineInfoDto.getUuid());
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

    public boolean SetToDB(String uuid){
        return databaseService.setToDB(uuid);
    }

    public List<ImageDetailDto> getImagesByCategoryAndUser(String category,String userIdStr){
        List<ImageDetailDto> dtoList = databaseService.getImagesByCategoryAndUser(category, userIdStr);
        return dtoList;
    }

    public List<ShrineInfoDto> getShrineInfo() {
        return databaseService.getShrineInfo();
    }

    public TopInfoDto topInfo(String userId) {
        TopInfoDto topInfo = new TopInfoDto();
        CountInfo countInfo = new CountInfo();

        int flowerCountImage = databaseService.getCount("flower",userId);
        int flowerAll = databaseService.getAll("flower");

        FlowerCountInfo flowerCountInfo = new FlowerCountInfo();
        flowerCountInfo.setCount(flowerCountImage);
        flowerCountInfo.setAll(flowerAll);
        countInfo.setFlower(flowerCountInfo);

        int shrineCountImage = databaseService.getCount("shrine",userId);
        int shrineAll = databaseService.getAll("shrine");

        ShrineCountInfo shrineCountInfo = new ShrineCountInfo();
        shrineCountInfo.setCount(shrineCountImage);
        shrineCountInfo.setAll(shrineAll);
        countInfo.setShrine(shrineCountInfo);

        double countImage = flowerCountImage + shrineCountImage;
        double countAll = flowerAll + shrineAll;

        double percent = (countImage*100)/countAll;

        countInfo.setPercent(percent);
        topInfo.setQuiz(getAllQuiz());
        topInfo.setCount(countInfo);
        return topInfo;
    }

}