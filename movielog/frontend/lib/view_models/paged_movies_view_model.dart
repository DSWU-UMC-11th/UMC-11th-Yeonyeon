import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../core/load_phase.dart';
import '../core/safe_notify.dart';
import '../data/models/tmdb_movie_dto.dart';
import '../data/services/tmdb_movie_service.dart';

class PagedMoviesViewModel extends ChangeNotifier with SafeNotify {
  PagedMoviesViewModel(
    this.service, {
    this.genreId,
    this.query,
    this.isSessionCurrent,
  });
  final TmdbMovieService service;
  final int? genreId;
  final String? query;
  final bool Function(int version)? isSessionCurrent;
  final List<TmdbMovieDto> movies = [];
  final Set<int> _ids = {};
  LoadPhase phase = LoadPhase.initial;
  bool loadingMore = false;
  String? message;
  int page = 0, totalPages = 1, _generation = 0, _sessionVersion = 0;
  int? _activeGenre;
  String? _activeQuery;
  bool get hasNextPage => page < totalPages;
  bool _isCurrent(int generation, int session) =>
      isAlive &&
      generation == _generation &&
      session == _sessionVersion &&
      (isSessionCurrent?.call(session) ?? true);

  Future<void> loadInitial({
    int? selectedGenreId,
    String? searchQuery,
    required int sessionVersion,
  }) async {
    final generation = ++_generation;
    _sessionVersion = sessionVersion;
    _activeGenre = selectedGenreId ?? genreId;
    _activeQuery = searchQuery ?? query;
    movies.clear();
    _ids.clear();
    page = 0;
    totalPages = 1;
    phase = LoadPhase.loading;
    loadingMore = false;
    message = null;
    notifyIfAlive();
    await _fetch(
      generation,
      1,
      genre: _activeGenre,
      search: _activeQuery,
      sessionVersion: sessionVersion,
      initial: true,
    );
  }

  Future<void> loadNextPage({required int sessionVersion}) async {
    if (!isAlive ||
        loadingMore ||
        phase == LoadPhase.loading ||
        !hasNextPage ||
        sessionVersion != _sessionVersion) {
      return;
    }
    loadingMore = true;
    message = null;
    notifyIfAlive();
    await _fetch(
      _generation,
      page + 1,
      genre: _activeGenre,
      search: _activeQuery,
      sessionVersion: sessionVersion,
      initial: false,
    );
  }

  Future<void> _fetch(
    int generation,
    int requested, {
    int? genre,
    String? search,
    required int sessionVersion,
    required bool initial,
  }) async {
    try {
      final result = (search != null)
          ? await service.searchMovies(query: search, page: requested)
          : await service.discoverMovies(page: requested, genreId: genre);
      if (!_isCurrent(generation, sessionVersion)) return;
      for (final movie in result.results) {
        if (_ids.add(movie.id)) movies.add(movie);
      }
      page = requested;
      totalPages = result.totalPages;
      phase = movies.isEmpty ? LoadPhase.empty : LoadPhase.success;
    } on DioException catch (error) {
      if (!_isCurrent(generation, sessionVersion)) return;
      message = error.message ?? '영화를 불러오지 못했습니다.';
      if (initial) phase = LoadPhase.error;
    } catch (_) {
      if (!_isCurrent(generation, sessionVersion)) return;
      message = '영화 응답을 처리하지 못했습니다.';
      if (initial) phase = LoadPhase.error;
    } finally {
      if (_isCurrent(generation, sessionVersion)) {
        loadingMore = false;
        notifyIfAlive();
      }
    }
  }
}
