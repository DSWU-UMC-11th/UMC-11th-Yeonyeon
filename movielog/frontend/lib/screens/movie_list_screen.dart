import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/models/tmdb_genre_dto.dart';
import '../data/services/tmdb_movie_service.dart';
import '../core/load_phase.dart';
import '../view_models/auth_view_model.dart';
import '../view_models/paged_movies_view_model.dart';
import '../widgets/movie/tmdb_movie_card.dart';
import '../widgets/movie/movie_page_footer.dart';

class MovieListScreen extends StatefulWidget {
  const MovieListScreen({super.key});
  @override
  State<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  List<TmdbGenreDto> genres = const [];
  int? selected;
  @override
  void initState() {
    super.initState();
    _loadGenres();
  }

  Future<void> _loadGenres() async {
    try {
      final result = await context.read<TmdbMovieService>().fetchGenres();
      if (mounted) setState(() => genres = result);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) => Consumer<PagedMoviesViewModel>(
    builder: (context, vm, _) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 12, 4),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  '영화',
                  style: TextStyle(
                    color: Color(0xFF6750A4),
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                tooltip: '영화 검색',
                onPressed: () => context.push('/movies/search'),
                icon: const Icon(Icons.search),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 52,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            scrollDirection: Axis.horizontal,
            itemCount: genres.length + 1,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final TmdbGenreDto? genre = i == 0 ? null : genres[i - 1];
              return ChoiceChip(
                label: Text(genre?.name ?? '전체'),
                selected: genre?.id == selected,
                onSelected: (_) {
                  setState(() => selected = genre?.id);
                  vm.loadInitial(
                    selectedGenreId: selected,
                    sessionVersion: context
                        .read<AuthViewModel>()
                        .sessionVersion,
                  );
                },
              );
            },
          ),
        ),
        Expanded(
          child: vm.phase == LoadPhase.loading && vm.movies.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : vm.phase == LoadPhase.error && vm.movies.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(vm.message ?? '영화를 불러오지 못했습니다.'),
                      TextButton(
                        onPressed: () => vm.loadInitial(
                          selectedGenreId: selected,
                          sessionVersion: context
                              .read<AuthViewModel>()
                              .sessionVersion,
                        ),
                        child: const Text('다시 시도'),
                      ),
                    ],
                  ),
                )
              : vm.phase == LoadPhase.empty
              ? const Center(child: Text('조건에 맞는 영화가 없습니다.'))
              : CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      sliver: SliverGrid.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: .64,
                            ),
                        itemCount: vm.movies.length,
                        itemBuilder: (_, i) =>
                            TmdbMovieCard(movie: vm.movies[i]),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: MoviePageFooter(
                        loading: vm.loadingMore,
                        hasNext: vm.hasNextPage,
                        error: vm.loadingMore
                            ? null
                            : (vm.page > 0 ? vm.message : null),
                        onPressed: () => vm.loadNextPage(
                          sessionVersion: context
                              .read<AuthViewModel>()
                              .sessionVersion,
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ],
    ),
  );
}
