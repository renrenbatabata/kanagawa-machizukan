package com.example.backend.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Embeddable;
import lombok.Data;

import java.io.Serializable;
import java.util.Objects;

@Data
@Embeddable
public class UserPhotoKey implements Serializable {
    @Column(name = "user_id")
    private Integer userId;

    @Column(name = "image_id")
    private Integer imageId;

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        UserPhotoKey that = (UserPhotoKey) o;
        return Objects.equals(userId, that.userId) && Objects.equals(imageId, that.imageId);
    }

    @Override
    public int hashCode() {
        return Objects.hash(userId, imageId);
    }
}