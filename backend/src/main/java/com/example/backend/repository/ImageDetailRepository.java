package com.example.backend.repository;

import com.example.backend.entity.ImageDetailEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ImageDetailRepository extends JpaRepository<ImageDetailEntity, Integer> {

    List<ImageDetailEntity> findByCategoryAndUserId(String category, String userId);

    List<ImageDetailEntity> findByCategoryAndUserIdAndName(String category, String userId, String name);

}