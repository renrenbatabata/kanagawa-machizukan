package com.example.backend.entity;

import jakarta.persistence.*;
import lombok.Data;
import org.springframework.data.annotation.CreatedDate;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Data
@Table(name = "image_details")
public class ImageDetailEntity {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id; // テーブルの主キー、自動生成される画像 ID

    @Column(nullable = false, length = 50)
    private String category;
    @Column(nullable = false)
    private String name;
    private String family; //〇科
    private String genius;
    @CreatedDate
    @Column(name = "shooting_date")
    private LocalDateTime shootingDate; // 撮影日

    @Column(name = "shooting_location")
    private String address;
    @Lob
    @Column(name = "image_data")
    private byte[] imageData; // 画像データそのもの (BLOB 型として保存)
    @Column(name = "user_id")
    private String userId;
}