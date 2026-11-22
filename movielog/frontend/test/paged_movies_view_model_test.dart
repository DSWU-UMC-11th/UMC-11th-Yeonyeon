import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movielog/data/models/tmdb_movie_dto.dart';
import 'package:movielog/data/models/tmdb_movie_page.dart';
import 'package:movielog/data/services/tmdb_movie_service.dart';
import 'package:movielog/view_models/paged_movies_view_model.dart';

void main() {
  group('PagedMoviesViewModel', () {
    test('holds existing cards while loading the next page and hides footer at end', () async {
      final service = _FakeTmdbMovieService();
      service.discover = ({required page, genreId}) async => page == 1
          ? _page(page: 1, totalPages: 2, ids: [1])
          : _page(page: 2, totalPages: 2, ids: [2]);
      final viewModel = PagedMoviesViewModel(service);

      await viewModel.loadInitial(sessionVersion: 1);
      final pending = viewModel.loadNextPage(sessionVersion: 1);
      expect(viewModel.loadingMore, isTrue);
      expect(viewModel.movies.map((movie) => movie.id), [1]);
      await pending;

      expect(viewModel.movies.map((movie) => movie.id), [1, 2]);
      expect(viewModel.page, 2);
      expect(viewModel.hasNextPage, isFalse);
      viewModel.dispose();
    });

    test(
      'retries the same failed page and leaves existing cards in place',
      () async {
        final service = _FakeTmdbMovieService();
        var pageTwoCalls = 0;
        service.discover = ({required page, genreId}) async {
          if (page == 1) return _page(page: 1, totalPages: 2, ids: [1]);
          pageTwoCalls++;
          if (pageTwoCalls == 1) {
            throw DioException(
              requestOptions: RequestOptions(path: '/discover/movie'),
            );
          }
          return _page(page: 2, totalPages: 2, ids: [2]);
        };
        final viewModel = PagedMoviesViewModel(service);

        await viewModel.loadInitial(sessionVersion: 1);
        await viewModel.loadNextPage(sessionVersion: 1);
        expect(viewModel.page, 1);
        expect(viewModel.movies.map((movie) => movie.id), [1]);
        expect(viewModel.message, isNotNull);

        await viewModel.loadNextPage(sessionVersion: 1);
        expect(pageTwoCalls, 2);
        expect(viewModel.page, 2);
        expect(viewModel.movies.map((movie) => movie.id), [1, 2]);
        viewModel.dispose();
      },
    );

    test('ignores a slower response from the previous genre', () async {
      final service = _FakeTmdbMovieService();
      final oldGenre = Completer<TmdbMoviePageDto>();
      service.discover = ({required page, genreId}) {
        if (genreId == null) return oldGenre.future;
        return Future.value(_page(page: 1, totalPages: 1, ids: [28]));
      };
      final viewModel = PagedMoviesViewModel(service);

      final oldRequest = viewModel.loadInitial(sessionVersion: 1);
      await viewModel.loadInitial(selectedGenreId: 28, sessionVersion: 1);
      oldGenre.complete(_page(page: 1, totalPages: 1, ids: [1]));
      await oldRequest;

      expect(viewModel.movies.map((movie) => movie.id), [28]);
      viewModel.dispose();
    });

    test(
      'ignores a slower response from the previous submitted search',
      () async {
        final service = _FakeTmdbMovieService();
        final oldSearch = Completer<TmdbMoviePageDto>();
        service.search = ({required query, required page}) => query == 'old'
            ? oldSearch.future
            : Future.value(_page(page: 1, totalPages: 1, ids: [2]));
        final viewModel = PagedMoviesViewModel(service);

        final oldRequest = viewModel.loadInitial(
          searchQuery: 'old',
          sessionVersion: 1,
        );
        await viewModel.loadInitial(searchQuery: 'new', sessionVersion: 1);
        oldSearch.complete(_page(page: 1, totalPages: 1, ids: [1]));
        await oldRequest;

        expect(viewModel.movies.map((movie) => movie.id), [2]);
        viewModel.dispose();
      },
    );

    test(
      'does not apply a response after the route disposes its provider',
      () async {
        final service = _FakeTmdbMovieService();
        final pendingPage = Completer<TmdbMoviePageDto>();
        service.discover = ({required page, genreId}) => pendingPage.future;
        final viewModel = PagedMoviesViewModel(service);

        final request = viewModel.loadInitial(sessionVersion: 1);
        viewModel.dispose();
        pendingPage.complete(_page(page: 1, totalPages: 1, ids: [1]));
        await request;

        expect(viewModel.movies, isEmpty);
      },
    );

    test('does not apply a response from a previous account session', () async {
      final service = _FakeTmdbMovieService();
      final pendingPage = Completer<TmdbMoviePageDto>();
      var currentSession = 1;
      service.discover = ({required page, genreId}) => pendingPage.future;
      final viewModel = PagedMoviesViewModel(
        service,
        isSessionCurrent: (version) => version == currentSession,
      );

      final request = viewModel.loadInitial(sessionVersion: 1);
      currentSession = 2;
      pendingPage.complete(_page(page: 1, totalPages: 1, ids: [1]));
      await request;

      expect(viewModel.movies, isEmpty);
      viewModel.dispose();
    });
  });
}

class _FakeTmdbMovieService extends TmdbMovieService {
  _FakeTmdbMovieService() : super(Dio());

  Future<TmdbMoviePageDto> Function({required int page, int? genreId})?
  discover;
  Future<TmdbMoviePageDto> Function({required String query, required int page})?
  search;

  @override
  Future<TmdbMoviePageDto> discoverMovies({required int page, int? genreId}) =>
      discover?.call(page: page, genreId: genreId) ??
      Future.error(StateError('Unexpected discover request'));

  @override
  Future<TmdbMoviePageDto> searchMovies({
    required String query,
    required int page,
  }) =>
      search?.call(query: query, page: page) ??
      Future.error(StateError('Unexpected search request'));
}

TmdbMoviePageDto _page({
  required int page,
  required int totalPages,
  required List<int> ids,
}) => TmdbMoviePageDto(
  page: page,
  totalPages: totalPages,
  totalResults: ids.length,
  results: ids.map(_movie).toList(),
);

TmdbMovieDto _movie(int id) => TmdbMovieDto(
  id: id,
  title: '영화 $id',
  overview: '',
  posterPath: null,
  backdropPath: null,
  releaseDate: '2020-01-01',
  genreIds: const [],
  voteAverage: 0,
  popularity: 0,
);
