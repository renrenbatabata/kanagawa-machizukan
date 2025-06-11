package com.example.backend.dto;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
public class ImageDetailDto {
    private String imageData;
    private Integer id;
    private String category;
    private String name;
    //private String shootingLocation;
    private String shootingDate;
    private String address;
}