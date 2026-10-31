package com.umc.backend.service;

import com.umc.backend.dto.RatingResponse;
import com.umc.backend.entity.Rating;
import com.umc.backend.repository.MemberRepository;
import com.umc.backend.repository.RatingRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;

@Service
@RequiredArgsConstructor
public class RatingService {

    private final RatingRepository ratingRepository;
    private final MemberRepository memberRepository;

    /** 유저별 평점 전체 조회 (최신순) */
    @Transactional(readOnly = true)
    public List<RatingResponse> getRatingsByMember(Long memberId) {
        validateMemberExists(memberId);

        return ratingRepository.findByMember_MemberIdOrderByRatingIdDesc(memberId).stream()
                .map(RatingResponse::from)
                .toList();
    }

    /** 선택 미션: 페이지 단위로 잘라서 응답 (응답 모양은 동일한 배열) */
    @Transactional(readOnly = true)
    public List<RatingResponse> getRatingsByMember(Long memberId, int page, int size) {
        validateMemberExists(memberId);

        PageRequest pageRequest = PageRequest.of(page, size, Sort.by(Sort.Direction.DESC, "ratingId"));
        return ratingRepository.findByMember_MemberId(memberId, pageRequest).stream()
                .map(RatingResponse::from)
                .toList();
    }

    private void validateMemberExists(Long memberId) {
        if (!memberRepository.existsById(memberId)) {
            // @RestControllerAdvice로 예외를 한 곳에서 다루는 방법은 6주차에 배웁니다.
            // 지금은 Spring이 기본 제공하는 ResponseStatusException으로 404를 바로 응답합니다.
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "존재하지 않는 유저입니다.");
        }
    }
}
