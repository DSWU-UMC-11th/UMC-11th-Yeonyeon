import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/tmdb_movie_dto.dart';
import '../tmdb_poster_image.dart';

class TmdbMovieCard extends StatelessWidget {
  const TmdbMovieCard({
    super.key,
    required this.movie,
    this.showPopularity = false,
  });

  final TmdbMovieDto movie;
  final bool showPopularity;

  @override
  Widget build(BuildContext context) => GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: () => context.push('/movies/${movie.id}'),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Stack(
            fit: StackFit.expand,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: TmdbPosterImage(
                  posterPath: movie.posterPath,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
              if (showPopularity)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.72),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${movie.voteAverage.toStringAsFixed(1)} ★',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
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
        if (!showPopularity)
          Text(
            '${movie.releaseDate?.split('-').first ?? '연도 미상'} · ${movie.voteAverage.toStringAsFixed(1)}점',
            style: const TextStyle(color: Color(0xFF79747E), fontSize: 13),
          ),
      ],
    ),
  );
}
