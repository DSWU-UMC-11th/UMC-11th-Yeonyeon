import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../data/models/rating_request.dart';
import '../data/models/rating_dto.dart';
import '../data/models/tmdb_movie_dto.dart';
import '../data/services/rating_api_service.dart';
import '../data/services/auth_api_service.dart';
import 'auth_view_model.dart';
import 'signup_view_model.dart';

class MovieDetailViewModel extends ChangeNotifier {
  MovieDetailViewModel(this._ratingService, this.auth, this.movie);
  final RatingApiService _ratingService;
  final AuthViewModel auth;
  final TmdbMovieDto movie;
  SubmitStatus submitStatus = SubmitStatus.idle;
  String? submitMessage;
  RatingDto? createdRating;
  bool _disposed = false;

  Future<void> createRating({required int score, String? comment}) async {
    if (auth.status != AuthStatus.signedIn) {
      submitStatus = SubmitStatus.error;
      submitMessage = '먼저 로그인해 주세요.';
      notifyListeners();
      return;
    }
    if (submitStatus == SubmitStatus.submitting) return;
    submitStatus = SubmitStatus.submitting;
    submitMessage = null;
    notifyListeners();
    final version = auth.sessionVersion;
    try {
      final rating = await _ratingService.createRating(
        request: CreateRatingRequest(movieId: movie.id, score: score, comment: comment),
      );
      if (_disposed || version != auth.sessionVersion) return;
      createdRating = rating;
      submitStatus = SubmitStatus.success;
    } on DioException catch (error) {
      if (_disposed || version != auth.sessionVersion) return;
      submitStatus = SubmitStatus.error;
      submitMessage = writeErrorMessage(error);
      if (const {'AUTH401_2','AUTH401_3','AUTH401_4'}.contains(apiErrorCode(error))) await auth.expireSession();
    } on StateError catch (error) {
      if (_disposed || version != auth.sessionVersion) return;
      submitStatus = SubmitStatus.error;
      submitMessage = error.message.toString();
    }
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
