import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/models/tmdb_genre_dto.dart';
import '../data/models/tmdb_movie_dto.dart';
import '../view_models/movie_list_view_model.dart';
import '../widgets/movie/tmdb_movie_card.dart';

class MovieListScreen extends StatelessWidget {
  const MovieListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 8, 12, 4),
          child: Text(
            '영화',
            style: TextStyle(
              color: Color(0xFF6750A4),
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Expanded(
          child: Consumer<MovieListViewModel>(
            builder: (context, viewModel, child) {
              final isLoading =
                  viewModel.status == MovieListLoadStatus.loading ||
                  viewModel.status == MovieListLoadStatus.idle;
              return Column(
                children: [
                  SizedBox(
                    height: 52,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      scrollDirection: Axis.horizontal,
                      itemCount: viewModel.genres.length + 1,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final TmdbGenreDto? genre = index == 0
                            ? null
                            : viewModel.genres[index - 1];
                        final selected = genre?.id == viewModel.selectedGenreId;
                        return ChoiceChip(
                          label: Text(genre?.name ?? '전체'),
                          selected: selected,
                          showCheckmark: false,
                          onSelected: isLoading
                              ? null
                              : (_) => context
                                    .read<MovieListViewModel>()
                                    .selectGenre(genre?.id),
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: switch (viewModel.status) {
                      MovieListLoadStatus.idle ||
                      MovieListLoadStatus.loading => const MovieListLoading(),
                      MovieListLoadStatus.error => MovieListError(
                        message: viewModel.message,
                        onRetry: () =>
                            context.read<MovieListViewModel>().loadInitial(),
                      ),
                      MovieListLoadStatus.empty => const MovieListEmpty(),
                      MovieListLoadStatus.success => MovieGrid(
                        movies: viewModel.movies,
                      ),
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class MovieGrid extends StatelessWidget {
  const MovieGrid({super.key, required this.movies});

  final List<TmdbMovieDto> movies;

  @override
  Widget build(BuildContext context) => GridView.builder(
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 0.64,
    ),
    itemCount: movies.length,
    itemBuilder: (context, index) => TmdbMovieCard(movie: movies[index]),
  );
}

class MovieListLoading extends StatelessWidget {
  const MovieListLoading({super.key});

  @override
  Widget build(BuildContext context) =>
      const Center(child: CircularProgressIndicator());
}

class MovieListEmpty extends StatelessWidget {
  const MovieListEmpty({super.key});

  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('조건에 맞는 영화가 없습니다.'));
}

class MovieListError extends StatelessWidget {
  const MovieListError({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String? message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.error_outline),
        const SizedBox(height: 12),
        Text(message ?? '영화를 불러오지 못했습니다.'),
        const SizedBox(height: 16),
        FilledButton(onPressed: onRetry, child: const Text('다시 시도')),
      ],
    ),
  );
}
