import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../core/load_phase.dart';
import '../core/map_bounded.dart';
import '../core/safe_notify.dart';
import '../core/session_guard.dart';
import '../data/models/favorite_list_item.dart';
import '../data/services/favorite_api_service.dart';
import '../data/services/tmdb_movie_service.dart';

class FavoritesViewModel extends ChangeNotifier with SafeNotify {
  FavoritesViewModel(this.api, this.moviesApi, this.guard);
  final FavoriteApi api;
  final TmdbMovieService moviesApi;
  final SessionGuard guard;
  List<FavoriteListItem> items = const [];
  LoadPhase phase = LoadPhase.initial;
  String? message;
  bool hasMovieFailures = false;
  int _generation = 0, _accountVersion = -1;
  Future<void> refresh() async {
    if (!isAlive) return;
    final generation = ++_generation, session = guard.version;
    if (!guard.isSignedIn) {
      items = const [];
      phase = LoadPhase.error;
      message = '로그인이 필요합니다.';
      notifyIfAlive();
      return;
    }
    if (_accountVersion != session) {
      items = const [];
      _accountVersion = session;
    }
    phase = LoadPhase.loading;
    message = null;
    hasMovieFailures = false;
    notifyIfAlive();
    try {
      final favorites = await api.fetchFavorites();
      if (!isAlive || !guard.isCurrent(session) || generation != _generation) {
        return;
      }
      final results = await mapBounded(favorites, 5, (favorite) async {
        dynamic movie;
        try {
          movie = await moviesApi.fetchMovieDetails(favorite.movieId);
        } catch (_) {}
        return FavoriteListItem(favorite: favorite, movie: movie);
      });
      if (!isAlive || !guard.isCurrent(session) || generation != _generation) {
        return;
      }
      items = results.whereType<FavoriteListItem>().toList();
      hasMovieFailures = results.any((item) => item?.movie == null);
      phase = items.isEmpty ? LoadPhase.empty : LoadPhase.success;
    } on DioException catch (error) {
      if (!isAlive || !guard.isCurrent(session) || generation != _generation) {
        return;
      }
      phase = LoadPhase.error;
      message = error.message ?? '즐겨찾기를 불러오지 못했습니다.';
      await guard.handle(error, session);
    } catch (_) {
      if (!isAlive || !guard.isCurrent(session) || generation != _generation) {
        return;
      }
      phase = LoadPhase.error;
      message = '즐겨찾기 응답을 처리하지 못했습니다.';
    }
    if (isAlive && generation == _generation) notifyIfAlive();
  }
}
