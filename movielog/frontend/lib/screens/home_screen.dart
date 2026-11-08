import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/models/tmdb_movie_dto.dart';
import '../view_models/movie_home_view_model.dart';
import '../widgets/movie/tmdb_movie_card.dart';
import '../widgets/tmdb_poster_image.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MovieHomeViewModel>();
    final featured = viewModel.popularMovies.isEmpty
        ? null
        : viewModel.popularMovies.first;
    return PopScope(
      canPop: false,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'MovieLog',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  IconButton(
                    tooltip: '검색',
                    onPressed: () {},
                    icon: const Icon(Icons.search),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
              child: Text(
                '오늘은 어떤\n영화를 볼까요?',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: switch (viewModel.status) {
                MovieHomeLoadStatus.idle ||
                MovieHomeLoadStatus.loading => const SizedBox(
                  height: 220,
                  child: Center(child: CircularProgressIndicator()),
                ),
                MovieHomeLoadStatus.error => _HomeMessage(
                  message: viewModel.message ?? '인기 영화를 불러오지 못했어요.',
                  onRetry: () =>
                      context.read<MovieHomeViewModel>().loadPopular(),
                ),
                MovieHomeLoadStatus.empty => const _HomeMessage(
                  message: '표시할 인기 영화가 없습니다.',
                ),
                MovieHomeLoadStatus.success => _FeaturedMovieCard(
                  movie: featured!,
                ),
              },
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '인기 영화',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                  TextButton(
                    onPressed: () => context.go('/movies'),
                    child: const Text('전체보기 ›'),
                  ),
                ],
              ),
            ),
          ),
          if (viewModel.status == MovieHomeLoadStatus.success)
            SliverToBoxAdapter(
              child: SizedBox(
                height: 256,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: viewModel.popularMovies.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 12),
                  itemBuilder: (context, index) => SizedBox(
                    width: 140,
                    child: TmdbMovieCard(
                      movie: viewModel.popularMovies[index],
                      showPopularity: true,
                    ),
                  ),
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}

class _FeaturedMovieCard extends StatelessWidget {
  const _FeaturedMovieCard({required this.movie});
  final TmdbMovieDto movie;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => context.push('/movies/${movie.id}'),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: SizedBox(
        height: 534,
        child: Stack(
          fit: StackFit.expand,
          children: [
            TmdbPosterImage(
              posterPath: movie.posterPath,
              width: double.infinity,
              height: double.infinity,
            ),
            Container(color: Colors.black.withValues(alpha: 0.7)),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Chip(label: Text('인기 영화')),
                    const SizedBox(height: 12),
                    Text(
                      movie.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${movie.releaseDate?.split('-').first ?? '연도 미상'} · 평점 ${movie.voteAverage.toStringAsFixed(1)}',
                      style: const TextStyle(
                        color: Color(0xFFE3E0E8),
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: () => context.push('/movies/${movie.id}'),
                        icon: const Icon(Icons.info),
                        label: const Text('상세보기'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4F378A),
                          foregroundColor: Colors.white,
                          shape: const StadiumBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _HomeMessage extends StatelessWidget {
  const _HomeMessage({required this.message, this.onRetry});
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 220,
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message),
          if (onRetry != null)
            TextButton(onPressed: onRetry, child: const Text('다시 시도')),
        ],
      ),
    ),
  );
}
