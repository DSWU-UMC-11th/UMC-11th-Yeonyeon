package com.umc.backend.repository;

import com.umc.backend.entity.Rating;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface RatingRepository extends JpaRepository<Rating, Long> {

    // 최신순(ratingId 내림차순) 전체 조회
    List<Rating> findByMember_MemberIdOrderByRatingIdDesc(Long memberId);

    // 선택 미션: 페이지네이션 (정렬은 Pageable의 Sort로 지정)
    Page<Rating> findByMember_MemberId(Long memberId, Pageable pageable);
}
