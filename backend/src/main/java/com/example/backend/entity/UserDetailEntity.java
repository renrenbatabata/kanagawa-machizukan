package com.example.backend.entity;

import jakarta.persistence.*;
import lombok.Data;

@Entity
@Data
@Table(name = "user_details")
public class UserDetailEntity {
    @Id
    private String userId;
}