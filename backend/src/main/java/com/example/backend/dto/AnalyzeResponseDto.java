package com.example.backend.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import lombok.Getter;
import lombok.Setter;

import java.util.List;
import java.util.Map;

@Setter
@Getter
@JsonIgnoreProperties(ignoreUnknown = true) // 追加: 未知のプロパティを無視する
public class AnalyzeResponseDto {
    private String name_en;
    private String name;
    @JsonProperty("common_names")
    private List<String> commonNames;
    private Map<String, String> taxonomy;
    private String family;
    private String genius;
    private Description description;
    private String error;
    private String details;
    private String exception; // "exception" フィールドを追加
    private String status;     // "status" フィールドを追加

    @Setter
    @Getter
    public static class Description {
        private String value;
        private String citation;
        @JsonProperty("license_name")
        private String licenseName;
        @JsonProperty("license_url")
        private String licenseUrl;

        public Description(String value) {
            this.value = value;
        }

        public Description() {
        }
    }
}