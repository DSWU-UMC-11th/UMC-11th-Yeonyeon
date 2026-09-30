import 'package:flutter/material.dart';

import './mock_movies.dart';
import './movie.dart';
import './genre_chip_bar.dart';
import './movie_card.dart';

class MovieListScreen extends StatefulWidget {
  const MovieListScreen({super.key});

  @override
  State<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  String _selectedGenre = '전체';
  Set<String> _selectedGenres = {};

  List<Movie> get _filteredMovies {
    if (_selectedGenres.isNotEmpty) {
      return movies.where((movie) {
        final movieGenres = movie.genre
            .split(RegExp(r'[•/]'))
            .map((genre) => genre.trim())
            .toSet();
        return movieGenres.intersection(_selectedGenres).isNotEmpty;
      }).toList();
    }
    if (_selectedGenre == '전체') return movies;
    return movies.where((movie) {
      return movie.genre
          .split(RegExp(r'[•/]'))
          .map((genre) => genre.trim())
          .contains(_selectedGenre);
    }).toList();
  }

  Future<void> _openGenreFilter() async {
    final result = await showGenreFilterSheet(
      context,
      selectedGenres: _selectedGenres,
    );
    if (result == null) return;
    setState(() {
      _selectedGenres = result;
      _selectedGenre = '전체';
    });
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredMovies;

    return Column(
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
                tooltip: '검색',
                onPressed: () {},
                icon: const Icon(Icons.search),
              ),
              IconButton(
                tooltip: '장르 필터',
                onPressed: _openGenreFilter,
                icon: const Icon(Icons.tune, color: Color(0xFF6750A4)),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GenreChipBar(
            selectedGenre: _selectedGenre,
            onSelected: (genre) {
              setState(() {
                _selectedGenre = genre;
                _selectedGenres = {};
              });
            },
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: filtered.isEmpty
              ? const Center(child: Text('해당 장르의 영화가 없습니다.'))
              : GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.64,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) =>
                      MovieCard(movie: filtered[index]),
                ),
        ),
      ],
    );
  }
}
