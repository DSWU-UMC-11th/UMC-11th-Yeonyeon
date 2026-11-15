package com.umc.backend.controller;

import com.umc.backend.dto.*;
import com.umc.backend.interceptor.AuthInterceptor;
import com.umc.backend.service.MovieRecordService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequiredArgsConstructor
public class MovieRecordController {
    private final MovieRecordService movieRecordService;

    @PostMapping("/movie-records")
    public ResponseEntity<ApiResponse<MovieRecordResponse>> create(@RequestAttribute(AuthInterceptor.MEMBER_ID) Long memberId,
            @Valid @RequestBody CreateMovieRecordRequest request) {
        return ResponseEntity.status(201).body(ApiResponse.created("영화 기록을 저장했습니다.", movieRecordService.create(memberId, request)));
    }
}
