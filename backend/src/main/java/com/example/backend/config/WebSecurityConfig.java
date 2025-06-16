package com.example.backend.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.web.DefaultSecurityFilterChain;

@Configuration
@EnableWebSecurity
public class WebSecurityConfig {
    @Bean
    public DefaultSecurityFilterChain securityWebFilterChain(HttpSecurity http) throws Exception {
        http
                .csrf(csrf -> csrf.disable())
                .authorizeHttpRequests(auth -> auth
                        .requestMatchers(
                                "/", // ← ここに追加
                                "/images/**",
                                "/css/**",
                                "/js/**",
                                "/webjars/**",
                                "/authorization/**",
                                "/filter-error",
                                "/api/hello",
                                "/analyze",
                                "/allPictures",
                                "/quiz",
                                "/pictures",
                                "/DBAdd",
                                "/DBtest",
                                "/shrineInfo",
                                "/top"
                        ).permitAll()
                        .anyRequest().authenticated()
                );

        return http.build();
    }
}