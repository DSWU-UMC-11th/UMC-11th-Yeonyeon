import 'package:dio/dio.dart';

import '../models/check_result.dart';
import '../models/common_response.dart';
import '../models/sign_up_models.dart';

abstract interface class SignUpApi {
  Future<bool> checkNickname(String nickname);
  Future<bool> checkEmail(String email);
  Future<CommonResponse<SignUpResult>> signUp(CreateMemberRequest request);
}

class SignUpService implements SignUpApi {
  SignUpService(this._dio);
  final Dio _dio;

  @override
  Future<bool> checkNickname(String nickname) async {
    final encoded = Uri.encodeComponent(nickname.trim());
    final response = await _dio.get('/v6/members/nickname/$encoded');
    return CheckResult.fromJson(_unwrap(response.data)).available;
  }

  @override
  Future<bool> checkEmail(String email) async {
    final encoded = Uri.encodeComponent(email.trim());
    final response = await _dio.get('/v6/members/email/$encoded');
    return CheckResult.fromJson(_unwrap(response.data)).available;
  }

  @override
  Future<CommonResponse<SignUpResult>> signUp(CreateMemberRequest request) async {
    final response = await _dio.post('/v6/members', data: request.toJson());
    return CommonResponse<SignUpResult>.fromJson(
      response.data as Map<String, dynamic>,
      (value) => SignUpResult.fromJson(value as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> _unwrap(dynamic data) =>
      data is Map<String, dynamic> && data.containsKey('result')
      ? data['result'] as Map<String, dynamic>
      : data as Map<String, dynamic>;
}

String writeSignUpErrorMessage(DioException error) {
  final data = error.response?.data;
  final common = data is Map<String, dynamic>
      ? CommonResponse<Object?>.fromJson(data, (value) => value)
      : null;
  return common?.message ?? '회원가입에 실패했습니다. 잠시 후 다시 시도해 주세요.';
}
