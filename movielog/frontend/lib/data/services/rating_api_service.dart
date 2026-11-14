import 'package:dio/dio.dart';
import '../models/rating_dto.dart';
import '../models/rating_request.dart';
import '../models/common_response.dart';
import 'auth_api_service.dart';

class RatingApiService {
  RatingApiService(this._publicDio, this._authDio);
  final Dio _publicDio;
  final Dio _authDio;

  Future<List<RatingDto>> fetchMyRatings(int memberId) async {
    final response = await _publicDio.get('/v7/members/$memberId/ratings');
    final payload = response.data;
    final list = payload is Map<String, dynamic> ? payload['result'] : payload;
    if (list is! List) throw const FormatException('평점 목록 응답이 배열이 아닙니다.');
    return list.map((item) => RatingDto.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<RatingDto> createRating({required CreateRatingRequest request}) async {
    final response = await _authDio.post('/v7/ratings', data: request.toJson());
    return _parseRating(response.data);
  }

  Future<RatingDto> updateRating({required int ratingId, required int score, String? comment}) async {
    final response = await _authDio.patch('/v7/ratings/$ratingId', data: UpdateRatingRequest(score: score, comment: comment).toJson());
    return _parseRating(response.data);
  }

  Future<void> deleteRating({required int ratingId}) async {
    final response = await _authDio.delete('/v7/ratings/$ratingId');
    _parseVoid(response.data);
  }

  RatingDto _parseRating(Object? data) {
    if (data is! Map<String, dynamic>) throw const FormatException('평점 응답 형식이 올바르지 않습니다.');
    final common = CommonResponse<RatingDto>.fromJson(data, (value) => RatingDto.fromJson(value as Map<String, dynamic>));
    if (common.result == null || !common.isSuccess) throw FormatException(common.message);
    return common.result!;
  }

  void _parseVoid(Object? data) {
    if (data is! Map<String, dynamic>) throw const FormatException('삭제 응답 형식이 올바르지 않습니다.');
    final common = CommonResponse<Object?>.fromJson(data, (value) => value);
    if (!common.isSuccess) throw FormatException(common.message);
  }
}

String writeErrorMessage(DioException error) => apiErrorMessage(error);

bool shouldRefreshAfterRatingError(DioException error) => const {
  'AUTH401_2', 'AUTH401_3', 'AUTH401_4', 'RATING403_1', 'RATING404_1', 'RATING409_1',
}.contains(apiErrorCode(error));
