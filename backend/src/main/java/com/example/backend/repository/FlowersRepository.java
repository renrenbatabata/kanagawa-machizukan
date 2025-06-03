package com.example.backend.repository;

import com.example.backend.entity.FlowersInfoEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface FlowersRepository extends JpaRepository<FlowersInfoEntity, String> {

    @Query("SELECT f FROM FlowersInfoEntity f WHERE :name LIKE CONCAT('%', f.name_en, '%')")
    List<FlowersInfoEntity> findByNameEnIsContainedIn(@Param("name") String name);

    @Query("SELECT f FROM FlowersInfoEntity f WHERE f.name_en = :name")
    Optional<FlowersInfoEntity> findByNameEn(@Param("name") String name);
}