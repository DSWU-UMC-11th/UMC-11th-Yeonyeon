import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/models/tmdb_movie_dto.dart';
import '../data/services/tmdb_movie_service.dart';
import '../theme/app_colors.dart';
import '../widgets/tmdb_poster_image.dart';
import '../widgets/movie/rating_dialog.dart';

class MovieDetailScreen extends StatefulWidget {
  const MovieDetailScreen({super.key, required this.movieId});

  final int movieId;

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  late Future<TmdbMovieDto?> _movieFuture;
  double? _myRating;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _loadMovie();
  }

  void _loadMovie() {
    _movieFuture = context.read<TmdbMovieService>().findMovieById(
      widget.movieId,
    );
  }

  void _retry() => setState(_loadMovie);

  Future<void> _openRatingDialog() async {
    final result = await showDialog<double>(
      context: context,
      builder: (_) => RatingDialog(initialRating: _myRating ?? 0),
    );
    if (result == null || !mounted) return;
    setState(() => _myRating = result);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('별점 ${result.toStringAsFixed(1)}점을 남겼습니다.')),
    );
  }

  void _toggleFavorite() {
    setState(() => _isFavorite = !_isFavorite);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_isFavorite ? '즐겨찾기에 추가했습니다.' : '즐겨찾기에서 삭제했습니다.')),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.warmWhite,
    appBar: AppBar(
      backgroundColor: AppColors.warmWhite,
      foregroundColor: AppColors.violet,
      title: const Text('영화 상세 정보'),
    ),
    body: FutureBuilder<TmdbMovieDto?>(
      future: _movieFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('영화 정보를 불러오지 못했습니다.'),
                const SizedBox(height: 12),
                FilledButton(onPressed: _retry, child: const Text('다시 시도')),
              ],
            ),
          );
        }
        final movie = snapshot.data;
        if (movie == null) {
          return const Center(child: Text('영화 정보를 찾을 수 없습니다.'));
        }

        final year = movie.releaseDate?.split('-').first;
        final genres = movie.genreNames.isNotEmpty
            ? movie.genreNames
            : movie.genreIds.map((id) => '장르 $id').toList();
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: TmdbPosterImage(
                posterPath: movie.backdropPath ?? movie.posterPath,
                width: double.infinity,
                height: 300,
              ),
            ),
            const SizedBox(height: 20),
            Text(movie.title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              [
                if (year != null && year.isNotEmpty) year,
                if (movie.runtimeMinutes != null) '${movie.runtimeMinutes}분',
              ].join(' · '),
            ),
            const SizedBox(height: 10),
            Text('★ ${movie.voteAverage.toStringAsFixed(1)} / 10'),
            if (genres.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: genres
                    .map((name) => Chip(label: Text(name)))
                    .toList(),
              ),
            ],
            const SizedBox(height: 24),
            Text('줄거리', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(movie.overview.isEmpty ? '등록된 줄거리가 없습니다.' : movie.overview),
            if (_myRating != null) ...[
              const SizedBox(height: 16),
              Text('내가 남긴 평점: ${_myRating!.toStringAsFixed(1)}점'),
            ],
          ],
        );
      },
    ),
    bottomNavigationBar: SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _toggleFavorite,
                icon: Icon(
                  _isFavorite ? Icons.bookmark : Icons.bookmark_border,
                ),
                label: Text(_isFavorite ? '즐겨찾기 완료' : '즐겨찾기'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilledButton.icon(
                onPressed: _openRatingDialog,
                icon: const Icon(Icons.rate_review_outlined),
                label: const Text('평점 남기기'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
