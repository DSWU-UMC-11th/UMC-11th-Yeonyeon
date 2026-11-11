package com.umc.backend.controller;

import com.umc.backend.dto.ApiResponse;
import com.umc.backend.dto.CreateRatingRequest;
import com.umc.backend.dto.RatingResponse;
import com.umc.backend.dto.UpdateRatingRequest;
import com.umc.backend.interceptor.AuthInterceptor;
import com.umc.backend.service.RatingService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequiredArgsConstructor
public class RatingController {
    private final RatingService ratingService;

    // 특정 회원의 평점 목록은 공개 API로 유지합니다.
    @GetMapping("/members/{memberId}/ratings")
    public ApiResponse<List<RatingResponse>> getMemberRatings(@PathVariable Long memberId) {
        return ApiResponse.ok("평점 조회에 성공했습니다.", ratingService.getRatingsByMember(memberId));
    }

    @PostMapping("/ratings")
    public ResponseEntity<ApiResponse<RatingResponse>> create(
            @RequestAttribute(AuthInterceptor.MEMBER_ID) Long memberId,
            @Valid @RequestBody CreateRatingRequest request) {
        return ResponseEntity.status(201).body(ApiResponse.created("평점을 등록했습니다.",
                ratingService.create(memberId, request)));
    }

    @PatchMapping("/ratings/{ratingId}")
    public ResponseEntity<ApiResponse<RatingResponse>> update(
            @RequestAttribute(AuthInterceptor.MEMBER_ID) Long memberId,
            @PathVariable Long ratingId,
            @Valid @RequestBody UpdateRatingRequest request) {
        return ResponseEntity.ok(ApiResponse.ok("평점을 수정했습니다.",
                ratingService.update(memberId, ratingId, request)));
    }

    @DeleteMapping("/ratings/{ratingId}")
    public ResponseEntity<ApiResponse<Void>> delete(
            @RequestAttribute(AuthInterceptor.MEMBER_ID) Long memberId,
            @PathVariable Long ratingId) {
        ratingService.delete(memberId, ratingId);
        return ResponseEntity.ok(ApiResponse.ok("평점을 삭제했습니다.", null));
    }
}
