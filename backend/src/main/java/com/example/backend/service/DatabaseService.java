package com.example.backend.service;

import com.example.backend.dto.*;
import com.example.backend.entity.FlowersInfoEntity;
import com.example.backend.entity.ImageDetailEntity;
import com.example.backend.entity.QuizEntity;
import com.example.backend.entity.TempDetailsEntity;
import com.example.backend.repository.*;
import com.github.dozermapper.core.DozerBeanMapper;
import lombok.AllArgsConstructor;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional; // Optional をインポート
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@AllArgsConstructor
public class DatabaseService {

    private final DozerBeanMapper mapper;
    private final ImageDetailRepository imageDetailRepository;
    private final FlowersRepository flowersRepository;
    private final ShrineInfoRepository shrineInfoRepository;
    private final QuizRepository quizRepository;
    private final TempDetailsRepository tempDetailsRepository;

    public FlowersInfoDto flowerSetToDB(SaveRequestDto saveRequestDto) throws IOException {
        var flowerInfo = searchFlowerInfo(saveRequestDto.getAnalyzeResponseDto().getName_en());
        var dto = saveRequestDto.getAnalyzeResponseDto();

        TempDetailsEntity tempDetailsEntity = new TempDetailsEntity();

        if (flowerInfo != null) {
            System.out.println("FlowerInfo in not null ;)");
            tempDetailsEntity.setFamily(flowerInfo.getFamily());
            tempDetailsEntity.setGenius(flowerInfo.getGenius());
            tempDetailsEntity.setName(flowerInfo.getName_jp());
        } else {
            System.out.println("FlowerInfo is null :) ");
            // flowerInfo = new FlowersInfoDto(); // ここで新しいインスタンスを作る場合、最終的に返されるものと整合性を取る
            mapper.map(dto, tempDetailsEntity); // DozerMapper を使うなら、dto から tempDetailsEntity へマッピング
            if (dto.getTaxonomy() != null) {
                tempDetailsEntity.setFamily(dto.getTaxonomy().get("family"));
                tempDetailsEntity.setGenius(dto.getTaxonomy().get("genus"));
                // flowerInfo.setName_jp(dto.getTaxonomy().get("name")); // この行はtempDetailsEntityにマッピング済みのため不要
                tempDetailsEntity.setName(dto.getTaxonomy().get("name")); // tempDetailsEntity.setName() は taxonomy から設定
            } else {
                tempDetailsEntity.setFamily("no data.");
                tempDetailsEntity.setGenius(null);
                // flowerInfo.setName_jp("no data."); // この行はtempDetailsEntityにマッピング済みのため不要
                tempDetailsEntity.setName("no data."); // taxonomy が null の場合の tempDetailsEntity.setName() の設定
            }
            // flowersInfoDto が null の場合の初期化
            flowerInfo = new FlowersInfoDto(); // ここでインスタンスを生成して、以下のプロパティを設定
            flowerInfo.setFamily("no data.");
            flowerInfo.setGenius(null);
            flowerInfo.setName_en(dto.getName_en());
            flowerInfo.setName_jp(dto.getName()); // analyzeResponseDto.getName() を使用
            flowerInfo.setMeaning("no data.");
            if (dto.getDescription() != null) {
                flowerInfo.setDescription(dto.getDescription().getValue());
            } else {
                flowerInfo.setDescription("no data.");
            }
        }
        tempDetailsEntity.setImageData(saveRequestDto.getFile().getBytes());
        tempDetailsEntity.setShootingDate(LocalDate.now());
        tempDetailsEntity.setCategory(saveRequestDto.getCategory());
        tempDetailsEntity.setUserId(saveRequestDto.getUserId());
        tempDetailsEntity.setUuid(UUID.randomUUID().toString());
        tempDetailsRepository.save(tempDetailsEntity);
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

    public List<ImageDetailDto> getImagesByCategoryAndUser(String category, String userId) {
        List<ImageDetailEntity> imageDetailEntities = imageDetailRepository.findByCategoryAndUserId(category, userId);
        return imageDetailEntities.stream()
                .map(entity -> mapper.map(entity, ImageDetailDto.class))
                .collect(Collectors.toList());
    }

    public ShrineInfoDto ShrineSetToDB(SaveRequestDto saveRequestDto) throws IOException {
        var dto = saveRequestDto.getShrineAnalyzeResponceDto();
        if (dto.getError() == null) {
            var shrineInfoOptional = shrineInfoRepository.findById(dto.getName()); // Optional を受け取る
            ShrineInfoDto info = new ShrineInfoDto(); // まずは新しいDTOインスタンスを初期化

            if (shrineInfoOptional.isPresent()) { // Optional の中身があるかチェック
                var shrineInfo = shrineInfoOptional.get();
                String category = "shrine";
                List<ImageDetailEntity> existingItems = imageDetailRepository.findByCategoryAndUserIdAndName(category, saveRequestDto.getUserId(), shrineInfo.getName());

                if (existingItems.isEmpty()) {
                    info = mapper.map(shrineInfo, ShrineInfoDto.class); // マッピング
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
            } else {
                // shrineInfoRepository.findById(dto.getName()) が見つからない場合
                info.setError("ちかくにじんじゃがみつからないよ！"); // このエラーはAnalyzeServiceからのDTOエラーと混同しないように注意
                System.out.println("登録されている神社、見つからないってよ"); // DBに登録されていない神社が見つからないケース
            }
            return info;
        } else {
            // dto.getError() が null でない場合 (AnalyzeServiceからのエラー)
            ShrineInfoDto info = new ShrineInfoDto();
            info.setError("ちかくにじんじゃがみつからないよ！"); // このメッセージはAnalyzeServiceのエラーがそのまま反映されている可能性
            System.out.println("AnalyzeServiceからのエラー： " + dto.getError()); // ログにエラー内容を記録
            return info;
        }
    }

    public List<QuizDto> getAllQuiz() {
        List<QuizEntity> quizEntities = quizRepository.findAll();
        return quizEntities.stream()
                .map(entity -> mapper.map(entity, QuizDto.class))
                .collect(Collectors.toList());
    }

    // getPicturesById の修正
    public ItemReturnInfo getPicturesById(Integer id) {
        Optional<ImageDetailEntity> imageDetailEntityOptional = imageDetailRepository.findById(id);

        if (imageDetailEntityOptional.isEmpty()) {
            return null; // IDに対応する画像が見つからない場合
        }

        ImageDetailDto detailDto = mapper.map(imageDetailEntityOptional.get(), ImageDetailDto.class);
        String name = detailDto.getName();
        System.out.println(detailDto.getCategory());

        // category によって異なる ReturnInfo のインスタンスを生成して返す
        switch (detailDto.getCategory()) {
            case "flower" -> {
                var flowerInfoEntity = flowersRepository.findByName(name); // Optional で返される可能性あり
                FlowersInfoDto flowersInfoDto = null;
                if (flowerInfoEntity != null) { // findByNameがOptionalを返さない場合
                    flowersInfoDto = mapper.map(flowerInfoEntity, FlowersInfoDto.class);
                }

                FlowerItemReturnInfo returnInfo = new FlowerItemReturnInfo();
                returnInfo.setFlowersInfo(flowersInfoDto);
               // returnInfo.setDate(detailDto.getShootingDate() != null ? detailDto.getShootingDate().toString() : null);
                // detailDto の shootingDate はそのまま使用し、DTO側でnullを設定する必要がある場合は別途処理
                // detail.setShootingDate(null); // ここで null にすると元の ImageDetailDto が変更される
                returnInfo.setImageDetail(detailDto); // ImageDetailDto を設定
                return returnInfo;
            }
            case "shrine" -> {
                var shrineInfoEntityOptional = shrineInfoRepository.findById(name); // Optional で返される
                ShrineInfoDto shrineInfoDto = null;
                if (shrineInfoEntityOptional.isPresent()) {
                    shrineInfoDto = mapper.map(shrineInfoEntityOptional.get(), ShrineInfoDto.class);
                }

                ShrineItemReturnInfo returnInfo = new ShrineItemReturnInfo();
                returnInfo.setShrineInfo(shrineInfoDto);
                //returnInfo.setDate(detailDto.getShootingDate() != null ? detailDto.getShootingDate().toString() : null);
                // detailDto の shootingDate はそのまま使用
                // detail.setShootingDate(null);
                returnInfo.setImageDetail(detailDto); // ImageDetailDto を設定
                return returnInfo;
            }
            case "turtle" -> {
                // turtle カテゴリの場合は、適切な ReturnInfo を返すか、null を返すかの方針を決定
                System.out.println("Turtle category is not yet fully implemented for detailed info.");
                return null;
            }
            default -> {
                System.out.println("Category Error :( - Unknown category: " + detailDto.getCategory());
                return null;
            }
        }
    }
}