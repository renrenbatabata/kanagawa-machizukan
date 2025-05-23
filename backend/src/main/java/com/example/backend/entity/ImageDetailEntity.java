package com.example.backend.entity;

import jakarta.persistence.*;
import lombok.Data;

import java.time.LocalDate;

@Entity
@Data
@Table(name = "image_details")
public class ImageDetailEntity {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id; // テーブルの主キー、自動生成される画像 ID

    @Column(nullable = false, length = 50)
    private String category; // 画像のカテゴリ

    @Column(nullable = false)
    private String name; // 植物の名前など

    private String family; //〇科

    private String genius;


    @Column(name = "shooting_date")
    private LocalDate shootingDate; // 撮影日

    @Lob
    @Column(name = "image_data")
    private byte[] imageData; // 画像データそのもの (BLOB 型として保存)

    // ユーザーIDを追加
    @Column(name = "user_id")
    private Integer userId;
}