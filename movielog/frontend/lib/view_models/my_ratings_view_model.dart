import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../data/models/rating_with_movie.dart';
import '../data/models/tmdb_movie_dto.dart';
import '../data/services/rating_api_service.dart';
import '../data/services/auth_api_service.dart';
import '../data/services/tmdb_movie_service.dart';
import 'auth_view_model.dart';

enum MyRatingsLoadStatus { idle, loading, success, empty, error }

class MyRatingsViewModel extends ChangeNotifier {
  MyRatingsViewModel(this._service, this._movieService, this.auth, this.memberId);

  final RatingApiService _service;
  final TmdbMovieService _movieService;
  final AuthViewModel auth;
  final int memberId;
  final Map<int, TmdbMovieDto?> _movieCache = {};
  int _requestVersion = 0;
  bool _disposed = false;
  List<RatingWithMovie> ratings = const [];
  MyRatingsLoadStatus status = MyRatingsLoadStatus.idle;
  String? message;
  bool editing = false;
  bool isDeletingSelected = false;
  final Set<int> selectedRatingIds = {};
  String? refreshWarning;

  void toggleEditing() { editing = !editing; selectedRatingIds.clear(); notifyListeners(); }
  void cancelEditing() { editing = false; selectedRatingIds.clear(); notifyListeners(); }
  void toggleSelected(int id) { if (!selectedRatingIds.add(id)) selectedRatingIds.remove(id); notifyListeners(); }

  Future<void> _refreshAfterWrite() async {
    await load();
    if (status == MyRatingsLoadStatus.error) {
      refreshWarning = '저장은 완료됐지만 목록을 불러오지 못했습니다. 조회만 다시 시도해 주세요.';
    } else {
      refreshWarning = null;
    }
    notifyListeners();
  }

  Future<void> updateRating({required int ratingId, required int score, String? comment}) async {
    final sessionVersion = auth.sessionVersion;
    try {
      final updated = await _service.updateRating(ratingId: ratingId, score: score, comment: comment);
      if (_disposed || sessionVersion != auth.sessionVersion) return;
      ratings = ratings.map((entry) => entry.rating.ratingId == ratingId ? RatingWithMovie(rating: updated, movie: entry.movie) : entry).toList();
    } on DioException catch (error) {
      if (_disposed || sessionVersion != auth.sessionVersion) return;
      message = writeErrorMessage(error);
      notifyListeners();
      if (const {'AUTH401_2','AUTH401_3','AUTH401_4'}.contains(apiErrorCode(error))) await auth.expireSession();
      else if (shouldRefreshAfterRatingError(error)) await load();
      rethrow;
    }
    await _refreshAfterWrite();
  }

  Future<void> deleteRating(int ratingId) async {
    final sessionVersion = auth.sessionVersion;
    try {
      await _service.deleteRating(ratingId: ratingId);
      if (_disposed || sessionVersion != auth.sessionVersion) return;
      ratings = ratings.where((entry) => entry.rating.ratingId != ratingId).toList();
    } on DioException catch (error) {
      if (_disposed || sessionVersion != auth.sessionVersion) return;
      message = writeErrorMessage(error);
      notifyListeners();
      if (const {'AUTH401_2','AUTH401_3','AUTH401_4'}.contains(apiErrorCode(error))) await auth.expireSession();
      else if (shouldRefreshAfterRatingError(error)) await load();
      rethrow;
    }
    await _refreshAfterWrite();
  }

  Future<void> deleteSelectedRatings() async {
    if (isDeletingSelected || selectedRatingIds.isEmpty) return;
    final sessionVersion = auth.sessionVersion;
    isDeletingSelected = true; message = null; notifyListeners();
    var failed = 0;
    try {
      for (final id in selectedRatingIds.toList()) {
        if (_disposed || sessionVersion != auth.sessionVersion) return;
        try {
          await _service.deleteRating(ratingId: id);
          if (_disposed || sessionVersion != auth.sessionVersion) return;
          selectedRatingIds.remove(id);
        } on DioException catch (error) {
          if (_disposed || sessionVersion != auth.sessionVersion) return;
          failed++;
          message = writeErrorMessage(error);
          if (const {'AUTH401_2','AUTH401_3','AUTH401_4'}.contains(apiErrorCode(error))) {
            await auth.expireSession();
            return;
          }
        }
      }

    } finally {
      isDeletingSelected = false;
      notifyListeners();
    }
    await _refreshAfterWrite();
    if (failed > 0) {
      message = '$failed개 항목을 삭제하지 못했습니다. 선택된 항목을 다시 확인해 주세요.';
      notifyListeners();
    } else {
      cancelEditing();
    }
  }

  Future<void> load() async {
    final version = ++_requestVersion;
    final sessionVersion = auth.sessionVersion;
    status = MyRatingsLoadStatus.loading;
    message = null;
    notifyListeners();
    try {
      final rawRatings = await _service.fetchMyRatings(memberId);
      if (_disposed || version != _requestVersion || sessionVersion != auth.sessionVersion) return;
      final entries = <RatingWithMovie>[];
      final attemptedMovieLookups = <int>{};
      var missingMovies = 0;
      for (final rating in rawRatings) {
        if (_disposed || version != _requestVersion || sessionVersion != auth.sessionVersion) return;
        if (!_movieCache.containsKey(rating.movieId) &&
            attemptedMovieLookups.add(rating.movieId)) {
          try {
            _movieCache[rating.movieId] = await _movieService.findMovieById(
              rating.movieId,
            );
          } on DioException {
            // Keep the rating and let the view show a movie placeholder.
          }
        }
        final movie = _movieCache[rating.movieId];
        if (movie == null) missingMovies++;
        entries.add(RatingWithMovie(rating: rating, movie: movie));
      }
      if (_disposed || version != _requestVersion || sessionVersion != auth.sessionVersion) return;
      ratings = entries;
      status = entries.isEmpty
          ? MyRatingsLoadStatus.empty
          : MyRatingsLoadStatus.success;
      if (missingMovies > 0) message = '일부 영화 정보를 가져오지 못해 제목과 포스터를 대신 표시합니다.';
    } on DioException catch (error) {
      if (_disposed || version != _requestVersion || sessionVersion != auth.sessionVersion) return;
      status = MyRatingsLoadStatus.error;
      message = writeErrorMessage(error);
      if (const {'AUTH401_2','AUTH401_3','AUTH401_4'}.contains(apiErrorCode(error))) await auth.expireSession();
    }
    if (!_disposed && version == _requestVersion) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _requestVersion++;
    super.dispose();
  }
}
