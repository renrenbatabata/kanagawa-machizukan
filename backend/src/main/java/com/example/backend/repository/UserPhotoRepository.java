package com.example.backend.repository;

import com.example.backend.entity.UserPhotoEntity;
import com.example.backend.entity.UserPhotoKey;
import org.springframework.data.jpa.repository.JpaRepository;

public interface UserPhotoRepository extends JpaRepository<UserPhotoEntity, UserPhotoKey> {
}
