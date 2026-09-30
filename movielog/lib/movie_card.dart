import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import './mock_movies.dart';
import './movie.dart';

/// 홈 · 목록 화면에서 공통으로 사용하는 영화 카드.
/// GestureDetector의 onTap에서 Path Parameter로 상세 Route로 이동합니다.
class MovieCard extends StatelessWidget {
  const MovieCard({
    super.key,
    required this.movie,
    this.showPopularity = false,
  });

  final Movie movie;
  final bool showPopularity;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => context.push('/movies/${movie.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                MoviePoster(
                  movie: movie,
                  rating: showPopularity ? null : movie.rating,
                ),
                if (showPopularity && movie.popularRank != null)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: _RankBadge(rank: movie.popularRank!),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            movie.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          if (showPopularity)
            Row(
              children: [
                const Icon(Icons.star, color: Color(0xFFD5AD43), size: 14),
                const SizedBox(width: 4),
                Text(movie.popularityScore!.toStringAsFixed(1)),
              ],
            )
          else
            Text(
              '${movie.year} · ${movie.genre}',
              style: const TextStyle(color: Color(0xFF79747E), fontSize: 16),
            ),
        ],
      ),
    );
  }
}

class _RankBadge extends StatelessWidget {
  const _RankBadge({required this.rank});

  final int rank;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '$rank',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// 실제 포스터 이미지 대신 Mock 포스터(색상 + 아이콘 + 평점 뱃지)를 표시합니다.
class MoviePoster extends StatelessWidget {
  const MoviePoster({super.key, required this.movie, this.rating});

  final Movie movie;
  final double? rating;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(movie.posterAsset, fit: BoxFit.cover),
          if (rating != null)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xCC49454F),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, color: Colors.white, size: 13),
                    const SizedBox(width: 4),
                    Text(
                      rating!.toStringAsFixed(1),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
