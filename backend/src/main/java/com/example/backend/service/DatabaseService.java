package com.example.backend.service;

import com.example.backend.dto.FlowersInfoDto;
import com.example.backend.dto.SaveRequestDto;
import com.example.backend.entity.FlowersInfoEntity;
import com.example.backend.entity.ImageDetailEntity;
import com.example.backend.repository.FlowersRepository;
import com.example.backend.repository.ImageDetailRepository;
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

    public FlowersInfoDto setDB(SaveRequestDto saveRequestDto) throws IOException {
        var flowerInfo = searchFlowerInfo(saveRequestDto.getDto().getName_en());
        var dto = saveRequestDto.getDto();

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
        imageDetailEntity.setUserId(saveRequestDto.getUserId()); // ユーザーIDを設定

        // ImageDetailEntity を保存し、Hibernate に ID と version を管理させる
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
}