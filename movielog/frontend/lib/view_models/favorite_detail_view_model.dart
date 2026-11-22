import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../core/safe_notify.dart';
import '../core/session_guard.dart';
import '../data/services/favorite_api_service.dart';

class FavoriteDetailViewModel extends ChangeNotifier with SafeNotify {
  FavoriteDetailViewModel(this.api, this.guard, this.movieId);
  final FavoriteApi api;
  final SessionGuard guard;
  final int movieId;
  bool isFavorite = false,
      loading = true,
      submitting = false,
      initialized = false;
  String? error;
  Future<void> load() async {
    if (!isAlive) return;
    final version = guard.version;
    loading = true;
    error = null;
    notifyIfAlive();
    try {
      final state = await api.checkFavorite(movieId);
      if (!isAlive || !guard.isCurrent(version)) return;
      isFavorite = state.isFavorite;
      initialized = true;
    } on DioException catch (e) {
      if (!isAlive || !guard.isCurrent(version)) return;
      error = e.message;
      await guard.handle(e, version);
    } catch (_) {
      if (!isAlive || !guard.isCurrent(version)) return;
      error = '즐겨찾기 상태를 확인하지 못했습니다.';
    } finally {
      if (isAlive && guard.isCurrent(version)) {
        loading = false;
        notifyIfAlive();
      }
    }
  }

  Future<bool> toggle() async {
    if (!isAlive || submitting || loading || !guard.isSignedIn) return false;
    final version = guard.version, target = !isFavorite;
    submitting = true;
    error = null;
    notifyIfAlive();
    try {
      if (target) {
        try {
          await api.addFavorite(movieId);
        } on DioException catch (e) {
          if (e.type == DioExceptionType.connectionTimeout ||
              e.type == DioExceptionType.receiveTimeout ||
              e.type == DioExceptionType.sendTimeout) {
            // POST may have succeeded; resolve uncertainty with GET and never replay it.
            final checked = await api.checkFavorite(movieId);
            if (!isAlive || !guard.isCurrent(version)) return false;
            isFavorite = checked.isFavorite;
            if (!isFavorite) {
              error = '등록 결과를 확인하지 못했습니다. 상태를 다시 확인해 주세요.';
              return false;
            }
          } else {
            rethrow;
          }
        }
      } else {
        await api.removeFavorite(movieId);
      }
      if (!isAlive || !guard.isCurrent(version)) return false;
      isFavorite = target;
      return true;
    } on DioException catch (e) {
      if (!isAlive || !guard.isCurrent(version)) return false;
      error = e.message ?? '즐겨찾기를 변경하지 못했습니다.';
      if (e.response?.statusCode == 409 || e.response?.statusCode == 404) {
        try {
          isFavorite = (await api.checkFavorite(movieId)).isFavorite;
        } catch (_) {}
      }
      await guard.handle(e, version);
      return false;
    } catch (_) {
      if (!isAlive || !guard.isCurrent(version)) return false;
      error = '즐겨찾기를 변경하지 못했습니다.';
      return false;
    } finally {
      if (isAlive && guard.isCurrent(version)) {
        submitting = false;
        notifyIfAlive();
      }
    }
  }
}
