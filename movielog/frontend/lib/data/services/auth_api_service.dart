import 'package:dio/dio.dart';
import '../models/common_response.dart';
import '../models/login_models.dart';
import '../models/member_info.dart';

class AuthApiService {
  AuthApiService(this._publicDio, this._authDio);
  final Dio _publicDio;
  final Dio _authDio;

  Future<LoginResult> login(LoginRequest request) async {
    final response = await _publicDio.post('/v7/auth/login', data: request.toJson());
    return _parseResult(response.data, LoginResult.fromJson);
  }

  Future<MemberInfo> fetchMe() async {
    final response = await _authDio.get('/v7/members/me');
    return _parseResult(response.data, MemberInfo.fromJson);
  }

  Future<MemberInfo> updateNickname(String nickname) async {
    final response = await _authDio.patch('/v7/members/me', data: {'nickname': nickname.trim()});
    return _parseResult(response.data, MemberInfo.fromJson);
  }

  T _parseResult<T>(Object? data, T Function(Map<String, dynamic>) parse) {
    if (data is! Map<String, dynamic>) throw const FormatException('API 응답 형식이 올바르지 않습니다.');
    final response = CommonResponse<T>.fromJson(data, (value) => parse(value as Map<String, dynamic>));
    if (!response.isSuccess || response.result == null) throw FormatException(response.message);
    return response.result as T;
  }
}

String apiErrorCode(DioException error) {
  final data = error.response?.data;
  return data is Map<String, dynamic> ? data['code'] as String? ?? '' : '';
}

String apiErrorMessage(DioException error) {
  final data = error.response?.data;
  if (data is Map<String, dynamic>) return data['message'] as String? ?? '요청에 실패했습니다. 다시 시도해 주세요.';
  return '네트워크를 확인하고 다시 시도해 주세요.';
}
