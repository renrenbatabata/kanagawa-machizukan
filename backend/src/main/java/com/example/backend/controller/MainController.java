package com.example.backend.controller;

import com.example.backend.dto.*;
import com.example.backend.service.AnalyzeService;
import com.example.backend.service.DatabaseService;
import com.example.backend.service.LogService;
import com.example.backend.service.MainService;
import lombok.AllArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
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
    public ResponseEntity<ItemReturnInfo> analyze(@RequestPart("image") MultipartFile file,
                                                  @RequestParam("category") String category,
                                                  @RequestParam("userId") String userIdStr,
                                                  @RequestParam("latitude") String latitude, // 緯度
                                                  @RequestParam("longitude") String longitude) throws IOException {
        connectLog("analyze");
        SaveRequestDto saveRequestDto = new SaveRequestDto();
        saveRequestDto.setCategory(category);
        saveRequestDto.setUserId(userIdStr);
        saveRequestDto.setFile(file);

        ItemReturnInfo resultInfo = null; // 共通の戻り値型

        if ("flower".equals(category)) {
            // FlowersInfoDto を取得し、それを元に FlowerReturnInfo を作成
            AnalyzeResponseDto analyzeResponseDto = analyzeService.getFlowerAnalysis(file, latitude, longitude);
            saveRequestDto.setAnalyzeResponseDto(analyzeResponseDto);
            // mainService.flowerSetToDB が FlowerReturnInfo を返すように変更を想定
            resultInfo = mainService.flowerSetToDB(saveRequestDto);
/*
            if (resultInfo != null) { // resultInfo がnullでないことを確認
                logService.infoLog((FlowersInfoDto) ((FlowerItemReturnInfo) resultInfo).getFlowersInfo());
            }*/
            System.out.println(resultInfo); // resultInfo を直接出力
        } else if ("shrine".equals(category)) {
            // ShrineInfoDto を取得し、それを元に ShrineReturnInfo を作成
            ShrineAnalyzeResponceDto shrineAnalyzeResponseDto = analyzeService.getShrineAnalysis(file, latitude, longitude);
            saveRequestDto.setShrineAnalyzeResponceDto(shrineAnalyzeResponseDto);
            // mainService.shrineSetToDB が ShrineReturnInfo を返すように変更を想定
            resultInfo = mainService.shrineSetToDB(saveRequestDto);

            if (resultInfo != null) { // resultInfo がnullでないことを確認
                logService.shrineLog((ShrineInfoDto) ((ShrineItemReturnInfo) resultInfo).getShrineInfo());
            }
        } else {
            // 未対応のカテゴリの場合
            System.err.println("Unsupported category: " + category);
            return ResponseEntity.badRequest().build(); // 400 Bad Request を返す
        }

        // ここが重要！resultInfo が正常に設定された場合は 200 OK を返す
        if (resultInfo != null) {
            return ResponseEntity.ok(resultInfo); // 200 OK と共に結果を返す
        } else {
            // resultInfo が null の場合は、引き続き Internal Server Error を返す
            // これは、analyzeService や mainService のメソッドが null を返した場合に発生します
            System.err.println("Analysis or Save operation returned null for category: " + category);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    @PostMapping(value = "/allPictures")
    public List<ImageDetailDto> returnPictures(@RequestParam("userId") String userIdStr,
                                               @RequestParam("category") String category) {
        connectLog("allPictures");
        List<ImageDetailDto> imageDetailDto = databaseService.getImagesByCategoryAndUser(category, userIdStr);
        logService.imageDetailListLog(imageDetailDto);
        return imageDetailDto;
    }

    @PostMapping(value = "/pictures/{id}")
    public ResponseEntity<ItemReturnInfo> getPicturesById(@PathVariable("id") Integer id) {
        connectLog("getPicturesById|id=" + id);
        ItemReturnInfo info = databaseService.getPicturesById(id);

        if (info == null) {
            // データが見つからなかった場合は 404 Not Found を返す
            return ResponseEntity.notFound().build();
        }

        // ログ出力は、返された具体的なDTOの型によって分岐させる必要がある
        if (info instanceof FlowerItemReturnInfo) {
            FlowersInfoDto flowersInfoDto = ((FlowerItemReturnInfo) info).getFlowersInfo();
            if (flowersInfoDto != null) {
                System.out.println(flowersInfoDto);
            }
        } else if (info instanceof ShrineItemReturnInfo) {
            ShrineInfoDto shrineInfoDto = ((ShrineItemReturnInfo) info).getShrineInfo();
            if (shrineInfoDto != null) {
                System.out.println(shrineInfoDto);
            }
        }

        logService.imageDetailLog(info.getImageDetail()); // imageDetail は共通なので直接アクセス

        // 正常にデータが取得できた場合は 200 OK と共にデータを返す
        return ResponseEntity.ok(info);
    }

    @PostMapping("/quiz")
    public List<QuizDto> quiz() {
        connectLog("quiz");
        System.out.println(databaseService.getAllQuiz());
        return mainService.getAllQuiz();
    }

    @GetMapping("/")
    public String index() {
        connectLog("Hello");
        return "hello";
    }

    public void connectLog(String connectName) {
        System.out.println(" ");
        System.out.println("----接続完了:" + connectName + "----------------");
    }
}