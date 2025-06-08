package com.example.backend.dto;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;
import java.time.LocalDate;
@Data
public class ImageDetailDto {
    private Integer id;
    private String category;
    private String name;
    private String shootingLocation;
    private byte[] imageData;
}