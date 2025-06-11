package com.example.backend.controller;

import com.example.backend.dto.*;
import com.example.backend.service.AnalyzeService;
import com.example.backend.service.DatabaseService;
import com.example.backend.service.LogService;
import com.example.backend.service.MainService;
import lombok.AllArgsConstructor;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

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
                                                  @RequestParam("longitude") String longitude,
                                                  @RequestParam("address") String address
                                                  ) throws IOException {
        connectLog("analyze");
        SaveRequestDto saveRequestDto = new SaveRequestDto();
        saveRequestDto.setCategory(category);
        saveRequestDto.setUserId(userIdStr);
        saveRequestDto.setFile(file);
        saveRequestDto.setAddress(address);

        ItemReturnInfo resultInfo = null; // 共通の戻り値型

        if ("flower".equals(category)) {
            AnalyzeResponseDto analyzeResponseDto = analyzeService.getFlowerAnalysis(file, latitude, longitude);
            if (analyzeResponseDto != null) {
                saveRequestDto.setAnalyzeResponseDto(analyzeResponseDto);
                // mainService.flowerSetToDB が FlowerReturnInfo を返すように変更を想定
                resultInfo = mainService.flowerSetToTestDB(saveRequestDto);
                System.out.println(resultInfo); // resultInfo を直接出力
            }else{
                return null;
            }
        } else if ("shrine".equals(category)) {
            ShrineAnalyzeResponceDto shrineAnalyzeResponseDto = analyzeService.getShrineAnalysis(file, latitude, longitude);
            saveRequestDto.setShrineAnalyzeResponceDto(shrineAnalyzeResponseDto);
            resultInfo = mainService.shrineSetToDB(saveRequestDto);
            if (resultInfo != null) { // resultInfo がnullでないことを確認
                logService.shrineLog((ShrineInfoDto) ((ShrineItemReturnInfo) resultInfo).getShrineInfo());
            }
        } else {
            System.err.println("Unsupported category: " + category);
            return ResponseEntity.badRequest().build(); // 400 Bad Request を返す
        }
        if (resultInfo != null) {
            return ResponseEntity.ok(resultInfo); // 200 OK と共に結果を返す
        } else {
            System.err.println("Analysis or Save operation returned null for category: " + category);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    @PostMapping(value = "/allPictures")
    public List<ImageDetailDto> returnPictures(@RequestParam("userId") String userIdStr,
                                               @RequestParam("category") String category) {
        connectLog("allPictures/userId=" + userIdStr + "/category=" + category);
        List<ImageDetailDto> imageDetailDto = mainService.getImagesByCategoryAndUser(category, userIdStr);
        logService.imageDetailListLog(imageDetailDto);
        return imageDetailDto;
    }

    @GetMapping("/shrineInfo")
    public List<ShrineInfoDto> getShrineInfo(){
        connectLog("ShrineInfo");
        return mainService.getShrineInfo();
    }

    @PostMapping(value = "/pictures")
    public ResponseEntity<ItemReturnInfo> getPicturesById(@RequestParam("id") Integer id) {
        connectLog("getPicturesById|id=" + id);
        ItemReturnInfo info = databaseService.getPicturesById(id);
        if (info == null) {
            return ResponseEntity.notFound().build();
        }
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

    @GetMapping("/quiz")
    public List<QuizDto> quiz() {
        connectLog("quiz");
        System.out.println(databaseService.getAllQuiz());
        return mainService.getAllQuiz();
    }

    @PostMapping("/DBAdd")
    public HttpEntity<String> DBAdd(@RequestBody Map<String, String> uuid) {
        String newUuid = uuid.get("uuid");
        connectLog("DBAdd/uuid:" + uuid);
        boolean DBCheck = mainService.flowerSetToDB(newUuid);//trueなら正常
        if (DBCheck) {
            return ResponseEntity.ok("処理完了");
        }else{
            return ResponseEntity.badRequest().body("error");
        }
    }

    @GetMapping("/")
    public String index() {
        connectLog("Hello");
        return "hello";
    }

    public void connectLog(String connectName) {
        LocalDateTime time = LocalDateTime.now();
        System.out.println(" ");
        System.out.println("----" + time + "----接続完了:" + connectName + "----------------");
    }

    @PostMapping("/DBtest")
    public HttpEntity<String> test(@RequestParam(value = "uuid", required = false) String uuid) {
        connectLog("TEST");
        System.out.println("uuid=" + uuid);
        boolean DBCheck = mainService.flowerSetToDB(uuid);//trueなら正常
        if (DBCheck) {
            return ResponseEntity.ok("処理完了");
        }else{
            return ResponseEntity.badRequest().body("error");
        }
    }
}