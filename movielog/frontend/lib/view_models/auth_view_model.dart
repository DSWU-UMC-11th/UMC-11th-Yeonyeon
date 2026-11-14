import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../data/models/login_models.dart';
import '../data/models/member_info.dart';
import '../data/services/auth_api_service.dart';
import '../data/services/token_storage.dart';

enum AuthStatus {
  initializing,
  signedOut,
  authenticating,
  signedIn,
  retryRequired,
}

enum MemberLoadStatus { idle, loading, success, error }

class AuthViewModel extends ChangeNotifier {
  AuthViewModel(this._api, this._storage);
  final AuthApiService _api;
  final TokenStorage _storage;
  AuthStatus status = AuthStatus.initializing;
  MemberLoadStatus memberStatus = MemberLoadStatus.idle;
  MemberInfo? member;
  String? message;
  bool sessionExpired = false;
  int _sessionVersion = 0;
  int get sessionVersion => _sessionVersion;
  bool _disposed = false;
  Future<void>? _tokenWrite;

  Future<void> initialize() async {
    final version = ++_sessionVersion;
    status = AuthStatus.initializing;
    _notify();
    try {
      final token = await _storage.read();
      if (!_isCurrent(version)) return;
      if (token == null || token.isEmpty) {
        status = AuthStatus.signedOut;
        _notify();
        return;
      }
      await restoreSession();
    } catch (_) {
      if (_isCurrent(version)) {
        status = AuthStatus.retryRequired;
        message = '로그인 상태를 확인하지 못했어요. 다시 시도해 주세요.';
        _notify();
      }
    }
  }

  Future<void> restoreSession() async {
    final version = _sessionVersion;
    status = AuthStatus.initializing;
    _notify();
    try {
      final me = await _withTokenMemberId(await _api.fetchMe());
      if (!_isCurrent(version)) return;
      member = me;
      memberStatus = MemberLoadStatus.success;
      status = AuthStatus.signedIn;
      message = null;
    } on DioException catch (error) {
      if (!_isCurrent(version)) return;
      if (_isAuthError(error)) {
        await _clearCurrentSession(expired: true);
        return;
      }
      status = AuthStatus.retryRequired;
      message = '네트워크를 확인한 뒤 다시 시도해 주세요.';
    } catch (_) {
      if (!_isCurrent(version)) return;
      status = AuthStatus.retryRequired;
      message = '회원 정보 응답을 확인할 수 없습니다. 다시 시도해 주세요.';
    }
    _notify();
  }

  Future<bool> login(String email, String password) async {
    if (status == AuthStatus.authenticating) return false;
    final version = ++_sessionVersion;
    status = AuthStatus.authenticating;
    message = null;
    _notify();
    try {
      final result = await _api.login(
        LoginRequest(email: email, password: password),
      );
      if (!_isCurrent(version)) return false;
      _tokenWrite = _storage.write(result.accessToken);
      await _tokenWrite;
      member = null;
      memberStatus = MemberLoadStatus.idle;
      status = AuthStatus.signedIn;
      _notify();
      return true;
    } on DioException catch (error) {
      if (!_isCurrent(version)) return false;
      status = AuthStatus.signedOut;
      message = apiErrorMessage(error);
      _notify();
      return false;
    } catch (_) {
      if (!_isCurrent(version)) return false;
      status = AuthStatus.signedOut;
      message = '로그인 결과를 확인하지 못했습니다.';
      _notify();
      return false;
    }
  }

  Future<void> loadMember() async {
    if (status != AuthStatus.signedIn) return;
    final version = _sessionVersion;
    memberStatus = MemberLoadStatus.loading;
    _notify();
    try {
      member = await _withTokenMemberId(await _api.fetchMe());
      if (!_isCurrent(version)) return;
      memberStatus = MemberLoadStatus.success;
      message = null;
    } on DioException catch (error) {
      if (!_isCurrent(version)) return;
      if (_isAuthError(error)) {
        await _clearCurrentSession(expired: true);
        return;
      }
      memberStatus = MemberLoadStatus.error;
      message = '내 정보를 불러오지 못했어요.';
    } catch (_) {
      if (!_isCurrent(version)) return;
      memberStatus = MemberLoadStatus.error;
      message = '회원 정보 응답을 확인할 수 없습니다. 다시 시도해 주세요.';
    }
    _notify();
  }

  Future<bool> updateNickname(String nickname) async {
    final value = nickname.trim();
    if (value.length < 2 || value.length > 12) {
      message = '닉네임은 2자 이상 12자 이하여야 합니다.';
      _notify();
      return false;
    }
    final version = _sessionVersion;
    try {
      final updated = await _withTokenMemberId(await _api.updateNickname(value));
      if (!_isCurrent(version)) return false;
      final current = member;
      member = MemberInfo(
        memberId: updated.memberId ?? current?.memberId,
        email: updated.email,
        nickname: updated.nickname,
        createdAt: updated.createdAt,
      );
      message = null;
      _notify();
      return true;
    } on DioException catch (error) {
      if (!_isCurrent(version)) return false;
      if (_isAuthError(error)) {
        await _clearCurrentSession(expired: true);
        return false;
      }
      message = apiErrorMessage(error);
      _notify();
      return false;
    }
  }

  Future<void> logout() async => _clearCurrentSession(expired: false);
  Future<void> expireSession() async => _clearCurrentSession(expired: true);
  Future<void> _clearCurrentSession({required bool expired}) async {
    ++_sessionVersion;
    member = null;
    memberStatus = MemberLoadStatus.idle;
    sessionExpired = expired;
    status = AuthStatus.signedOut;
    message = null;
    try {
      await _tokenWrite;
    } catch (_) {}
    try {
      await _storage.delete();
    } catch (_) {}
    _notify();
  }

  void consumeSessionExpired() {
    sessionExpired = false;
  }

  bool _isAuthError(DioException error) => const {
    'AUTH401_2',
    'AUTH401_3',
    'AUTH401_4',
  }.contains(apiErrorCode(error));

  Future<MemberInfo> _withTokenMemberId(MemberInfo info) async {
    if (info.memberId != null) return info;
    try {
      final token = await _storage.read();
      if (token == null) return info;
      final parts = token.split('.');
      if (parts.length != 3) return info;
      final payload = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      );
      if (payload is! Map<String, dynamic>) return info;
      final subject = payload['sub'];
      final memberId = subject is num ? subject.toInt() : int.tryParse('$subject');
      if (memberId == null) return info;
      return MemberInfo(
        memberId: memberId,
        email: info.email,
        nickname: info.nickname,
        createdAt: info.createdAt,
      );
    } catch (_) {
      return info;
    }
  }

  bool _isCurrent(int version) => !_disposed && version == _sessionVersion;
  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    ++_sessionVersion;
    super.dispose();
  }
}
