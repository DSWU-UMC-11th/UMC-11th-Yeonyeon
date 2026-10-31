package com.umc.backend.controller;

import com.umc.backend.dto.RatingResponse;
import com.umc.backend.service.RatingService;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequiredArgsConstructor
@RequestMapping("/members")
public class RatingController {

    private final RatingService ratingService;

    /**
     * GET /members/{memberId}/ratings
     * - page, size 가 없으면 전체 목록(필수 미션)
     * - GET /members/{memberId}/ratings?page=0&size=10 처럼 주면 페이지 단위(선택 미션)
     */
    @GetMapping("/{memberId}/ratings")
    public List<RatingResponse> getMemberRatings(
            @PathVariable Long memberId,
            @RequestParam(required = false) @Min(0) Integer page,
            @RequestParam(required = false) @Min(1) @Max(100) Integer size) {

        if (page == null && size == null) {
            return ratingService.getRatingsByMember(memberId);
        }
        return ratingService.getRatingsByMember(
                memberId,
                page == null ? 0 : page,
                size == null ? 10 : size);
    }
}
