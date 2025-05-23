package com.example.backend.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.Data;
import org.springframework.context.annotation.Primary;

@Entity
@Data
@Table(name = "flowers")
public class FlowersInfoEntity {

    private String name_jp;
    @Id
    private String name_en;
    @Column(name = "family_jp")
    private String family;//○科
    @Column(name = "genus_jp")
    private String genius;//〇目
    private String meaning;
    private String description;
}
