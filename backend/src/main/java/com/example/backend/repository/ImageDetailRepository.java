package com.example.backend.repository;

import com.example.backend.entity.ImageDetailEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ImageDetailRepository extends JpaRepository<ImageDetailEntity, Integer> {

    List<ImageDetailEntity> findByCategoryAndUserId(String category, String userId);

    List<ImageDetailEntity> findByCategoryAndUserIdAndName(String category, String userId, String name);

    List<ImageDetailEntity> findByUserId(String userId);

    @Query("SELECT COUNT(DISTINCT i.name) FROM ImageDetailEntity i WHERE i.category = :category AND i.userId = :userId")
    int countDistinctNameByCategoryAndUserId(@Param("category") String category, @Param("userId") String userId);

}