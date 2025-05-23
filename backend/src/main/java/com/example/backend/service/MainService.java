package com.example.backend.service;

import com.example.backend.dto.FlowersInfoDto;
import com.example.backend.dto.SaveRequestDto;
import com.github.dozermapper.core.DozerBeanMapper;
import lombok.AllArgsConstructor;
import org.springframework.stereotype.Service;

import java.io.IOException;

@Service
@AllArgsConstructor
public class MainService {

    private final DatabaseService databaseService;
    private final DozerBeanMapper mapper;

    public FlowersInfoDto setDB(SaveRequestDto saveRequestDto) throws IOException {
        return databaseService.setDB(saveRequestDto);
    }
}
