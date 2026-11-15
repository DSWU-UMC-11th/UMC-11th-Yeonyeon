package com.umc.backend.service;

import com.umc.backend.dto.CreateFavoriteRequest;
import com.umc.backend.dto.FavoriteResponse;
import com.umc.backend.entity.Favorite;
import com.umc.backend.entity.Member;
import com.umc.backend.exception.ApiException;
import com.umc.backend.repository.FavoriteRepository;
import com.umc.backend.repository.MemberRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.List;

@Service
@RequiredArgsConstructor
public class FavoriteService {
    private final FavoriteRepository favoriteRepository;
    private final MemberRepository memberRepository;

    @Transactional
    public FavoriteResponse create(Long memberId, CreateFavoriteRequest request) {
        Member member = memberRepository.findById(memberId)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "MEMBER404_1", "해당 회원을 찾을 수 없습니다."));
        if (favoriteRepository.existsByMember_MemberIdAndMovieId(memberId, request.movieId())) {
            throw new ApiException(HttpStatus.CONFLICT, "FAVORITE409_1", "이미 이 영화를 즐겨찾기하셨습니다.");
        }
        return FavoriteResponse.from(favoriteRepository.save(new Favorite(member, request.movieId())));
    }

    @Transactional(readOnly = true)
    public List<FavoriteResponse> getMine(Long memberId) {
        return favoriteRepository.findByMember_MemberIdOrderByFavoriteIdDesc(memberId).stream()
                .map(FavoriteResponse::from).toList();
    }

    @Transactional(readOnly = true)
    public boolean isFavorite(Long memberId, Long movieId) {
        return favoriteRepository.existsByMember_MemberIdAndMovieId(memberId, movieId);
    }

    @Transactional
    public void delete(Long memberId, Long movieId) {
        Favorite favorite = favoriteRepository.findByMember_MemberIdAndMovieId(memberId, movieId)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "FAVORITE404_1", "즐겨찾기를 찾을 수 없습니다."));
        favoriteRepository.delete(favorite);
    }
}
