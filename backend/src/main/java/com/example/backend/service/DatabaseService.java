package com.example.backend.service;

import com.example.backend.dto.*;
import com.example.backend.entity.*;
import com.example.backend.repository.*;
import com.github.dozermapper.core.DozerBeanMapper;
import lombok.AllArgsConstructor;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.*;
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

    public FlowersInfoDto flowerSetToTestDB(SaveRequestDto saveRequestDto) throws IOException {
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
            return null;
        }
        tempDetailsEntity.setImageData(saveRequestDto.getFile().getBytes());
        tempDetailsEntity.setShootingDate(LocalDateTime.now());
        tempDetailsEntity.setCategory(saveRequestDto.getCategory());
        tempDetailsEntity.setUserId(saveRequestDto.getUserId());
        String uuid = UUID.randomUUID().toString();
        tempDetailsEntity.setUuid(uuid);
        tempDetailsEntity.setAddress(saveRequestDto.getAddress());
        tempDetailsRepository.save(tempDetailsEntity);
        flowerInfo.setUuid(uuid);
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
        if (Objects.equals(category, "all")) {
            List<ImageDetailEntity> imageDetailEntities = imageDetailRepository.findByUserId(userId);
            return imageDetailEntities.stream()
                    .map(entity -> {
                        ImageDetailDto dto = new ImageDetailDto();
                        dto.setId(entity.getId());
                        dto.setCategory(entity.getCategory());
                        dto.setName(entity.getName());
                        dto.setAddress(entity.getAddress());
                        if (entity.getShootingDate() != null) {
                            dto.setShootingDate(entity.getShootingDate().toString());
                        } else {
                            dto.setShootingDate(null);
                        }

                        if(entity.getImageData()!=null){
                            dto.setImageData(Base64.getEncoder().encodeToString(entity.getImageData()));
                        }else{
                            dto.setImageData(null);
                        }
                        return dto;
                    }).collect(Collectors.toList());
        } else {
            List<ImageDetailEntity> imageDetailEntities = imageDetailRepository.findByCategoryAndUserId(category, userId);
            return imageDetailEntities.stream()
                    .map(entity -> {
                        ImageDetailDto dto = new ImageDetailDto();
                        dto.setId(entity.getId());
                        dto.setCategory(entity.getCategory());
                        dto.setName(entity.getName());
                        dto.setAddress(entity.getAddress());
                        if (entity.getShootingDate() != null) {
                            dto.setShootingDate(entity.getShootingDate().toString());
                        } else {
                            dto.setShootingDate(null);
                        }

                        if(entity.getImageData()!=null){
                            dto.setImageData(Base64.getEncoder().encodeToString(entity.getImageData()));
                        }else{
                            dto.setImageData(null);
                        }
                        return dto;
                    }).collect(Collectors.toList());
        }
    }

//    private List<ImageDetailDto> mapImageDetailEntityToDto(ImageDetailEntity entity){
//        return imageDetailEntities.stream()
//                .map(entity -> {
//                    ImageDetailDto dto = new ImageDetailDto();
//                    dto.setId(entity.getId());
//                    dto.setCategory(entity.getCategory());
//                    dto.setName(entity.getName());
//                    if (entity.getShootingDate() != null) {
//                        dto.setShootingDate(entity.getShootingDate().toString());
//                    } else {
//                        dto.setShootingDate(null);
//                    }
//
//                    if(entity.getImageData()!=null){
//                        dto.setImageData(Base64.getEncoder().encodeToString(entity.getImageData()));
//                    }else{
//                        dto.setImageData(null);
//                    }
//                    return dto;
//                }).collect(Collectors.toList());    }

    public ShrineInfoDto ShrineSetToDB(SaveRequestDto saveRequestDto) throws IOException {
        var dto = saveRequestDto.getShrineAnalyzeResponceDto();
        TempDetailsEntity tempDetailsEntity = new TempDetailsEntity(); // TempDetailsEntity を初期化
        ShrineInfoDto resultInfo = new ShrineInfoDto(); // 戻り値となる ShrineInfoDto を初期化
        // UUIDを生成し、TempDetailsEntityに設定
        String uuid = UUID.randomUUID().toString();
        tempDetailsEntity.setUuid(uuid);
        resultInfo.setUuid(uuid); // 戻り値のDTOにもUUIDを設定
        if (dto.getError() == null) {
            // AnalyzeService からエラーがない場合
            var shrineInfoOptional = shrineInfoRepository.findById(dto.getName());
            if (shrineInfoOptional.isPresent()) {
                var shrineInfo = shrineInfoOptional.get();
                tempDetailsEntity.setName(shrineInfo.getName()); // shrineInfoから取得
                tempDetailsEntity.setAddress(shrineInfo.getName());
                tempDetailsEntity.setImageData(saveRequestDto.getFile().getBytes());
                tempDetailsEntity.setShootingDate(LocalDateTime.now());
                tempDetailsEntity.setCategory(saveRequestDto.getCategory());
                tempDetailsEntity.setUserId(saveRequestDto.getUserId());
                tempDetailsRepository.save(tempDetailsEntity); // TempDetailsEntity を保存
                resultInfo = mapper.map(shrineInfo, ShrineInfoDto.class); // shrineInfoの内容をresultInfoにマッピング
                resultInfo.setUuid(uuid); // 生成したUUIDを設定
                resultInfo.setError(null); // エラーなし
                System.out.println("✅ Shrine registered to TempDetails: " + resultInfo.getName());

            } else {
                resultInfo.setError("ちかくにじんじゃがみつからないよ！"); // 新しいメッセージ
                System.out.println("データベースに登録されていない神社が見つかりました（" + dto.getName() + "）。");

                tempDetailsEntity.setName(dto.getName()); // AnalyzeResponseDtoから名前を設定
                tempDetailsEntity.setFamily("no data."); // デフォルト値
                tempDetailsEntity.setGenius(null); // デフォルト値
                tempDetailsEntity.setImageData(saveRequestDto.getFile().getBytes());
                tempDetailsEntity.setShootingDate(LocalDateTime.now());
                tempDetailsEntity.setCategory(saveRequestDto.getCategory());
                tempDetailsEntity.setUserId(saveRequestDto.getUserId());
                tempDetailsRepository.save(tempDetailsEntity); // TempDetailsEntity を保存
                mapper.map(dto, resultInfo);
                resultInfo.setUuid(uuid);
            }

        } else {
            // dto.getError() が null でない場合 (AnalyzeServiceからのエラー)
            resultInfo.setError("ちかくにじんじゃがみつからないよ！");
            System.out.println("❌ AnalyzeService からエラーが返されました: " + dto.getError());
            resultInfo.setName(dto.getName() != null ? dto.getName() : "unknown"); // AnalyzeServiceのエラーだが名前があれば設定
        }
        return resultInfo; // 最終的な ShrineInfoDto を返す
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

        ImageDetailDto detailDto = new ImageDetailDto();
        detailDto.setId(imageDetailEntityOptional.get().getId());
        detailDto.setCategory(imageDetailEntityOptional.get().getCategory());
        detailDto.setName(imageDetailEntityOptional.get().getName());
        detailDto.setAddress(imageDetailEntityOptional.get().getAddress());
        detailDto.setShootingDate(imageDetailEntityOptional.get().getShootingDate().toString());
        detailDto.setImageData(Base64.getEncoder().encodeToString(imageDetailEntityOptional.get().getImageData()));

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

    public boolean flowerSetToDB(String uuid) {
        TempDetailsEntity info = tempDetailsRepository.findById(uuid).orElse(null);
        if (info != null) {
            ImageDetailEntity entity = mapper.map(info, ImageDetailEntity.class);
            System.out.println(entity);
            imageDetailRepository.save(entity);
            return true;
        } else {
            System.out.println("DB is null");
            return false;
        }
    }

    public List<ShrineInfoDto> getShrineInfo() {
        List<ShrineInfoEntity> info = shrineInfoRepository.findAll();
        return info.stream()
                .map(entity -> mapper.map(entity, ShrineInfoDto.class))
                .collect(Collectors.toList());
    }
}