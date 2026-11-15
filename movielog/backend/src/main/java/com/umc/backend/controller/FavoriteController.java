package com.umc.backend.controller;

import com.umc.backend.dto.*;
import com.umc.backend.interceptor.AuthInterceptor;
import com.umc.backend.service.FavoriteService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequiredArgsConstructor
public class FavoriteController {
    private final FavoriteService favoriteService;

    @PostMapping("/favorites")
    public ResponseEntity<ApiResponse<FavoriteResponse>> create(@RequestAttribute(AuthInterceptor.MEMBER_ID) Long memberId,
            @Valid @RequestBody CreateFavoriteRequest request) {
        return ResponseEntity.status(201).body(ApiResponse.created("즐겨찾기를 등록했습니다.", favoriteService.create(memberId, request)));
    }

    @GetMapping("/favorites")
    public ApiResponse<List<FavoriteResponse>> getMine(@RequestAttribute(AuthInterceptor.MEMBER_ID) Long memberId) {
        return ApiResponse.ok("즐겨찾기를 조회했습니다.", favoriteService.getMine(memberId));
    }

    @GetMapping("/favorites/{movieId}")
    public ApiResponse<FavoriteStatusResponse> isFavorite(@RequestAttribute(AuthInterceptor.MEMBER_ID) Long memberId,
            @PathVariable Long movieId) {
        return ApiResponse.ok("즐겨찾기 여부를 조회했습니다.", new FavoriteStatusResponse(favoriteService.isFavorite(memberId, movieId)));
    }

    @DeleteMapping("/favorites/{movieId}")
    public ApiResponse<Void> delete(@RequestAttribute(AuthInterceptor.MEMBER_ID) Long memberId, @PathVariable Long movieId) {
        favoriteService.delete(memberId, movieId);
        return ApiResponse.ok("즐겨찾기를 해제했습니다.", null);
    }
}
