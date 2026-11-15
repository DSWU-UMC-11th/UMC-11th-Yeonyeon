package com.umc.backend.service;

import com.umc.backend.dto.*;
import com.umc.backend.entity.Favorite;
import com.umc.backend.entity.Member;
import com.umc.backend.entity.Rating;
import com.umc.backend.exception.ApiException;
import com.umc.backend.repository.FavoriteRepository;
import com.umc.backend.repository.MemberRepository;
import com.umc.backend.repository.RatingRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class MovieRecordService {
    private final MemberRepository memberRepository;
    private final RatingRepository ratingRepository;
    private final FavoriteRepository favoriteRepository;

    @Transactional
    public MovieRecordResponse create(Long memberId, CreateMovieRecordRequest request) {
        Member member = memberRepository.findById(memberId)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "MEMBER404_1", "해당 회원을 찾을 수 없습니다."));
        if (ratingRepository.existsByMember_MemberIdAndMovieId(memberId, request.movieId())) {
            throw new ApiException(HttpStatus.CONFLICT, "RATING409_1", "이미 이 영화에 평점을 남기셨습니다.");
        }
        Rating rating = ratingRepository.save(new Rating(member, request.movieId(), request.score(), request.comment()));
        Favorite favorite = null;
        if (request.addToFavorites()) {
            if (favoriteRepository.existsByMember_MemberIdAndMovieId(memberId, request.movieId())) {
                throw new ApiException(HttpStatus.CONFLICT, "FAVORITE409_1", "이미 이 영화를 즐겨찾기하셨습니다.");
            }
            favorite = favoriteRepository.save(new Favorite(member, request.movieId()));
        }
        return new MovieRecordResponse(RatingResponse.from(rating), favorite == null ? null : FavoriteResponse.from(favorite));
    }
}
