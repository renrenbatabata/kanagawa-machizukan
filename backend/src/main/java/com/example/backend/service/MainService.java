package com.example.backend.service;

import com.example.backend.dto.FlowersInfoDto;
import com.example.backend.dto.SaveRequestDto;
import com.example.backend.dto.ShrineInfoDto;
import com.github.dozermapper.core.DozerBeanMapper;
import lombok.AllArgsConstructor;
import org.springframework.stereotype.Service;

import java.io.IOException;

@Service
@AllArgsConstructor
public class MainService {

    private final DatabaseService databaseService;
    private final DozerBeanMapper mapper;

    public FlowersInfoDto flowerSetToDB(SaveRequestDto saveRequestDto) throws IOException {
        return databaseService.flowerSetToDB(saveRequestDto);
    }
    public ShrineInfoDto shrineSetToDB(SaveRequestDto saveRequestDto) throws IOException{
        return databaseService.ShrineSetToDB(saveRequestDto);
    }

}
