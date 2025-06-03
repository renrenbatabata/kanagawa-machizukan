package com.example.backend.dto;

import lombok.Data;
import java.time.LocalDate;
@Data
public class ImageDetailDto {
    private Integer id;
    private String category;
    private String name;
    private LocalDate shootingDate;
    private String shootingLocation;
    private byte[] imageData;
}