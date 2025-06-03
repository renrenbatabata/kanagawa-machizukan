package com.example.backend.service;

import com.example.backend.dto.*;
import com.example.backend.entity.FlowersInfoEntity;
import com.example.backend.entity.ImageDetailEntity;
import com.example.backend.repository.FlowersRepository;
import com.example.backend.repository.ImageDetailRepository;
import com.example.backend.repository.ShrineInfoRepository;
import com.github.dozermapper.core.DozerBeanMapper;
import lombok.AllArgsConstructor;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.time.LocalDate;
import java.util.List;
import java.util.ArrayList;
import java.util.stream.Collectors;

@Service
@AllArgsConstructor
public class DatabaseService {

    private final DozerBeanMapper mapper;
    private final ImageDetailRepository imageDetailRepository;
    private final FlowersRepository flowersRepository;
    private final ShrineInfoRepository shrineInfoRepository;

    public FlowersInfoDto flowerSetToDB(SaveRequestDto saveRequestDto) throws IOException {
        var flowerInfo = searchFlowerInfo(saveRequestDto.getAnalyzeResponseDto().getName_en());
        var dto = saveRequestDto.getAnalyzeResponseDto();

        ImageDetailEntity imageDetailEntity = new ImageDetailEntity();

        if (flowerInfo != null) {
            System.out.println("FlowerInfo in not null ;)");
            imageDetailEntity.setFamily(flowerInfo.getFamily());
            imageDetailEntity.setGenius(flowerInfo.getGenius());
            imageDetailEntity.setName(flowerInfo.getName_jp());
        } else {
            System.out.println("FlowerInfo is null :) ");
            flowerInfo = new FlowersInfoDto();
            mapper.map(dto, imageDetailEntity);
            if (dto.getTaxonomy() != null) {
                imageDetailEntity.setFamily(dto.getTaxonomy().get("family"));
                imageDetailEntity.setGenius(dto.getTaxonomy().get("genus"));
                flowerInfo.setName_jp(dto.getTaxonomy().get("name"));
                // imageDetailEntity.setName() を taxonomy から設定
                imageDetailEntity.setName(dto.getTaxonomy().get("name"));
            } else {
                imageDetailEntity.setFamily("no data.");
                imageDetailEntity.setGenius(null);
                flowerInfo.setName_jp("no data.");
                // taxonomy が null の場合の imageDetailEntity.setName() の設定
                imageDetailEntity.setName("no data."); // デフォルト値を設定するなど
            }
            flowerInfo.setFamily("no data.");
            flowerInfo.setGenius(null);
            flowerInfo.setName_en(dto.getName_en());
            flowerInfo.setName_jp(dto.getName());
            flowerInfo.setMeaning("no data.");
            if (dto.getDescription() != null) {
                flowerInfo.setDescription(dto.getDescription().getValue());
            } else {
                flowerInfo.setDescription("no data.");
            }
        }
        imageDetailEntity.setImageData(saveRequestDto.getFile().getBytes());
        imageDetailEntity.setShootingDate(LocalDate.now());
        imageDetailEntity.setCategory(saveRequestDto.getCategory());
        imageDetailEntity.setUserId(saveRequestDto.getUserId());
        imageDetailRepository.save(imageDetailEntity);

        return flowerInfo;
    }

    public FlowersInfoDto searchFlowerInfo(String name) {
        if (name == null || name.isEmpty()) {
            return null;
        }
        List<FlowersInfoEntity> foundEntities = flowersRepository.findByNameEnIsContainedIn(name);

        if (!foundEntities.isEmpty()) {
            return mapper.map(foundEntities.get(0), FlowersInfoDto.class);
        }
        return null;
    }

    public List<ImageDetailDto> getImagesByCategoryAndUser(String category, Integer userId) {
        List<ImageDetailEntity> imageDetailEntities = imageDetailRepository.findByCategoryAndUserId(category, userId);
        return imageDetailEntities.stream()
                .map(entity -> mapper.map(entity, ImageDetailDto.class))
                .collect(Collectors.toList());
    }

    public ShrineInfoDto ShrineSetToDB(SaveRequestDto saveRequestDto) throws IOException {
        var dto = saveRequestDto.getShrineAnalyzeResponceDto();
        if (dto.getError() == null) {
            var shrineInfo = shrineInfoRepository.findById(dto.getName()).orElse(null);
            ShrineInfoDto info = new ShrineInfoDto();
            if (shrineInfo != null) {
                String category = "shrine";
                List<ImageDetailEntity> existingItems = imageDetailRepository.findByCategoryAndUserIdAndName(category, saveRequestDto.getUserId(), shrineInfo.getName());
                if (existingItems.isEmpty()) {
                    info = mapper.map(shrineInfo, ShrineInfoDto.class);
                    ImageDetailEntity DBEntity = new ImageDetailEntity();
                    DBEntity.setName(info.getName());
                    DBEntity.setCategory(saveRequestDto.getCategory());
                    DBEntity.setUserId(saveRequestDto.getUserId());
                    DBEntity.setImageData(saveRequestDto.getFile().getBytes());
                    DBEntity.setShootingDate(LocalDate.now());
                    imageDetailRepository.save(DBEntity);
                } else {
                    info.setError("もう登録(とうろく)されているじんじゃだよ！");
                    System.out.println("重複してるので登録しない");
                }
            }
            return info;
        } else {
            ShrineInfoDto info = new ShrineInfoDto();
            info.setError("ちかくにじんじゃがみつからないよ！");
            System.out.println("登録されている神社、見つからないってよ");
            return info;
        }
    }
}