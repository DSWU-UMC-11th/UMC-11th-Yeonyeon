package com.umc.backend.repository;

import com.umc.backend.entity.Favorite;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.Optional;

public interface FavoriteRepository extends JpaRepository<Favorite, Long> {
    boolean existsByMember_MemberIdAndMovieId(Long memberId, Long movieId);
    List<Favorite> findByMember_MemberIdOrderByFavoriteIdDesc(Long memberId);
    Optional<Favorite> findByMember_MemberIdAndMovieId(Long memberId, Long movieId);
}
