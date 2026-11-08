import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/models/tmdb_movie_dto.dart';
import '../data/services/rating_api_service.dart';
import '../data/services/tmdb_movie_service.dart';
import '../theme/app_colors.dart';
import '../view_models/learning_member_session.dart';
import '../view_models/movie_detail_view_model.dart';
import '../view_models/signup_view_model.dart';
import '../widgets/movie/rating_dialog.dart';
import '../widgets/tmdb_poster_image.dart';

class MovieDetailScreen extends StatefulWidget {
  const MovieDetailScreen({super.key, required this.movieId, this.initialMovie});
  final int movieId;
  final TmdbMovieDto? initialMovie;

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  late final Future<TmdbMovieDto?> _movieFuture;

  @override
  void initState() {
    super.initState();
    _movieFuture = widget.initialMovie != null && widget.initialMovie!.id == widget.movieId
        ? Future.value(widget.initialMovie)
        : context.read<TmdbMovieService>().findMovieById(widget.movieId);
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<TmdbMovieDto?>(
    future: _movieFuture,
    builder: (context, snapshot) {
      if (snapshot.connectionState != ConnectionState.done) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      if (snapshot.hasError || snapshot.data == null) {
        return const Scaffold(body: Center(child: Text('영화를 불러오지 못했습니다.')));
      }
      final movie = snapshot.data!;
      return ChangeNotifierProvider<MovieDetailViewModel>(
        create: (context) => MovieDetailViewModel(
          context.read<RatingApiService>(),
          context.read<LearningMemberSession>().memberId,
          movie,
        ),
        child: _MovieDetailContent(movie: movie),
      );
    },
  );
}

class _MovieDetailContent extends StatefulWidget {
  const _MovieDetailContent({required this.movie});
  final TmdbMovieDto movie;
  @override
  State<_MovieDetailContent> createState() => _MovieDetailContentState();
}

class _MovieDetailContentState extends State<_MovieDetailContent> {
  bool _isFavorite = false;

  Future<void> _openRatingDialog() async {
    final vm = context.read<MovieDetailViewModel>();
    if (vm.memberId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('평점을 등록하려면 먼저 회원가입해 주세요.')));
      return;
    }
    final saved = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => RatingDialog(
        onSubmit: (score, comment) async {
          await vm.createRating(score: score, comment: comment);
          if (vm.submitStatus != SubmitStatus.success) {
            throw StateError(vm.submitMessage ?? '저장에 실패했습니다.');
          }
        },
      ),
    );
    if (!mounted || saved != true) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('평점을 등록했습니다. 마이페이지의 "내가 등록한 평점"에서 확인할 수 있습니다.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final movie = widget.movie;
    final year = movie.releaseDate?.split('-').first;
    final genres = movie.genreNames.isNotEmpty ? movie.genreNames : movie.genreIds.map((id) => '장르 $id').toList();
    return Scaffold(
      backgroundColor: AppColors.warmWhite,
      appBar: AppBar(backgroundColor: AppColors.warmWhite, foregroundColor: AppColors.violet, title: const Text('영화 상세 정보')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          ClipRRect(borderRadius: BorderRadius.circular(16), child: TmdbPosterImage(posterPath: movie.backdropPath ?? movie.posterPath, width: double.infinity, height: 300)),
          const SizedBox(height: 20),
          Text(movie.title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text([if (year != null && year.isNotEmpty) year, if (movie.runtimeMinutes != null) '${movie.runtimeMinutes}분'].join(' · ')),
          const SizedBox(height: 10),
          Text('★ ${movie.voteAverage.toStringAsFixed(1)} / 10'),
          if (genres.isNotEmpty) ...[const SizedBox(height: 12), Wrap(spacing: 8, runSpacing: 8, children: genres.map((name) => Chip(label: Text(name))).toList())],
          const SizedBox(height: 24),
          Text('줄거리', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(movie.overview.isEmpty ? '등록된 줄거리가 없습니다.' : movie.overview),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
          child: Row(children: [
            Expanded(child: OutlinedButton.icon(onPressed: () { setState(() => _isFavorite = !_isFavorite); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_isFavorite ? '즐겨찾기에 추가했습니다.' : '즐겨찾기에서 삭제했습니다.'))); }, icon: Icon(_isFavorite ? Icons.bookmark : Icons.bookmark_border), label: Text(_isFavorite ? '즐겨찾기 완료' : '즐겨찾기'))),
            const SizedBox(width: 8),
            Expanded(child: FilledButton.icon(onPressed: _openRatingDialog, icon: const Icon(Icons.rate_review_outlined), label: const Text('평점 남기기'))),
          ]),
        ),
      ),
    );
  }
}
