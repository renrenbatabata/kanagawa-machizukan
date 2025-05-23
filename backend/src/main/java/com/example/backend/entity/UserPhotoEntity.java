package com.example.backend.entity;

import jakarta.persistence.*;
import lombok.Data;

@Entity
@Data
@Table(name = "user_photos")
public class UserPhotoEntity {
    @EmbeddedId
    private UserPhotoKey id;

    @ManyToOne
    @JoinColumn(name = "user_id", referencedColumnName = "userId", insertable = false, updatable = false)
    private UserDetailEntity userDetail;

    @ManyToOne
    @JoinColumn(name = "image_id", referencedColumnName = "id", insertable = false, updatable = false)
    private ImageDetailEntity imageDetail;

    // 他の関連情報があればここに追加 (例: 保存日時など)
}