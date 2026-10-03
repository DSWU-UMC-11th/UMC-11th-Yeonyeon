import 'package:flutter/material.dart';

import 'fake_movie_service.dart';
import 'genre_chip_bar.dart';
import 'genre_preference.dart';
import 'mock_movies.dart';
import 'movie.dart';
import 'movie_card.dart';

class MovieListScreen extends StatefulWidget {
  const MovieListScreen({
    super.key,
    this.initialLoadMode = MovieLoadMode.success,
  });

  // Empty/Error 상태를 확인할 때만 지정합니다.
  final MovieLoadMode initialLoadMode;

  @override
  State<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  final _movieService = const FakeMovieService();
  final _genrePreference = GenrePreference();

  late Future<MovieListInitialData> _moviesFuture;
  String? _selectedGenre;

  @override
  void initState() {
    super.initState();
    _moviesFuture = _loadInitialData(widget.initialLoadMode);
  }

  Future<MovieListInitialData> _loadInitialData(MovieLoadMode mode) async {
    try {
      // 서로 의존하지 않는 영화 요청과 설정 읽기를 함께 시작합니다.
      final results = await Future.wait<Object>([
        _movieService.fetchMovies(mode: mode),
        _genrePreference.read(),
      ]);

      return MovieListInitialData(
        movies: results[0] as List<Movie>,
        selectedGenre: results[1] as String,
      );
    } on MovieLoadException catch (error, stackTrace) {
      // 오류 세부 정보는 로그에만 남기고 FutureBuilder로 전달합니다.
      debugPrint('영화 목록 요청 실패: $error');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    } finally {
      debugPrint('영화 목록 요청 종료');
    }
  }

  void _retry() {
    setState(() {
      _selectedGenre = null;
      _moviesFuture = _loadInitialData(MovieLoadMode.success);
    });
  }

  Future<void> _selectGenre(String genre) async {
    setState(() {
      _selectedGenre = genre;
    });

    try {
      await _genrePreference.save(genre);
    } catch (error, stackTrace) {
      debugPrint('장르 저장 실패: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('선택한 장르를 저장하지 못했습니다.')));
    }
  }

  List<Movie> _filterMovies(List<Movie> allMovies, String genre) {
    if (genre == '전체') return allMovies;

    return allMovies.where((movie) {
      final movieGenres = movie.genre
          .split(RegExp(r'[•/]'))
          .map((value) => value.trim());
      return movieGenres.contains(genre);
    }).toList();
  }

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
          child: FutureBuilder<MovieListInitialData>(
            future: _moviesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const MovieListLoading();
              }

              if (snapshot.hasError) {
                return MovieListError(onRetry: _retry);
              }

              final initialData = snapshot.data;
              if (initialData == null || initialData.movies.isEmpty) {
                return const MovieListEmpty();
              }

              final savedGenre = genres.contains(initialData.selectedGenre)
                  ? initialData.selectedGenre
                  : '전체';
              final selectedGenre = _selectedGenre ?? savedGenre;
              final filteredMovies = _filterMovies(
                initialData.movies,
                selectedGenre,
              );

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GenreChipBar(
                      selectedGenre: selectedGenre,
                      onSelected: _selectGenre,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: filteredMovies.isEmpty
                        ? const Center(child: Text('해당 장르의 영화가 없습니다.'))
                        : GridView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  childAspectRatio: 0.64,
                                ),
                            itemCount: filteredMovies.length,
                            itemBuilder: (context, index) =>
                                MovieCard(movie: filteredMovies[index]),
                          ),
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

class MovieListInitialData {
  const MovieListInitialData({
    required this.movies,
    required this.selectedGenre,
  });

  final List<Movie> movies;
  final String selectedGenre;
}

class MovieListLoading extends StatelessWidget {
  const MovieListLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class MovieListEmpty extends StatelessWidget {
  const MovieListEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('조건에 맞는 영화가 없습니다.'));
  }
}

class MovieListError extends StatelessWidget {
  const MovieListError({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline),
          const SizedBox(height: 12),
          const Text('영화를 불러오지 못했습니다.'),
          const SizedBox(height: 16),
          FilledButton(onPressed: onRetry, child: const Text('다시 시도')),
        ],
      ),
    );
  }
}
