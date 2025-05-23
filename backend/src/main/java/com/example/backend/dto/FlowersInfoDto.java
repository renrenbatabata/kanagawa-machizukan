package com.example.backend.dto;

import jakarta.persistence.Column;
import lombok.Data;

import java.util.List;

@Data
public class FlowersInfoDto{
    private List<String> common_names;
    private String name_jp;
    private String name_en;
    @Column(name="family_jp")
    private String family;//○科
    @Column(name="genius_jp")
    private String genius;//〇目
    private String meaning;//花言葉
    private String description;//説明
}
