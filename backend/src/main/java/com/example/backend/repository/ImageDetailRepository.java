package com.example.backend.repository;

import com.example.backend.entity.ImageDetailEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ImageDetailRepository extends JpaRepository<ImageDetailEntity, Integer> {

    List<ImageDetailEntity> findByCategoryAndUserId(String category, Integer userId);


}