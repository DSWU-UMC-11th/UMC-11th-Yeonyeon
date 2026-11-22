import 'package:dio/dio.dart';

import '../models/common_response.dart';
import '../models/favorite_dto.dart';

abstract interface class FavoriteApi {
  Future<List<FavoriteDto>> fetchFavorites();
  Future<FavoriteCheckDto> checkFavorite(int movieId);
  Future<FavoriteResponseDto> addFavorite(int movieId);
  Future<void> removeFavorite(int movieId);
}

class FavoriteApiService implements FavoriteApi {
  FavoriteApiService(this._dio);
  final Dio _dio;
  Future<Object?> _result(Response<dynamic> response) async {
    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw const FormatException('즐겨찾기 응답 형식이 올바르지 않습니다.');
    }
    final common = CommonResponse<Object?>.fromJson(data, (value) => value);
    if (!common.isSuccess) throw FormatException(common.message);
    return common.result;
  }

  @override
  Future<List<FavoriteDto>> fetchFavorites() async {
    final result = await _result(await _dio.get('/v8/favorites'));
    if (result is! List) throw const FormatException('즐겨찾기 목록이 배열이 아닙니다.');
    return result
        .map((e) => FavoriteDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<FavoriteCheckDto> checkFavorite(int movieId) async {
    final result = await _result(await _dio.get('/v8/favorites/$movieId'));
    if (result is! Map<String, dynamic>) {
      throw const FormatException('즐겨찾기 확인 응답이 올바르지 않습니다.');
    }
    return FavoriteCheckDto.fromJson(result, movieId: movieId);
  }

  @override
  Future<FavoriteResponseDto> addFavorite(int movieId) async {
    final result = await _result(
      await _dio.post('/v8/favorites', data: {'movieId': movieId}),
    );
    if (result is! Map<String, dynamic>) {
      throw const FormatException('즐겨찾기 등록 응답이 올바르지 않습니다.');
    }
    return FavoriteResponseDto.fromJson(result);
  }

  @override
  Future<void> removeFavorite(int movieId) async {
    await _result(await _dio.delete('/v8/favorites/$movieId'));
  }
}
