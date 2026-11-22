import 'package:dio/dio.dart';

import '../data/services/auth_api_service.dart';
import '../view_models/auth_view_model.dart';

class SessionGuard {
  const SessionGuard(this.auth);
  final AuthViewModel auth;
  int get version => auth.sessionVersion;
  bool get isSignedIn => auth.status == AuthStatus.signedIn;
  bool isCurrent(int captured) => captured == auth.sessionVersion && isSignedIn;
  Future<bool> handle(DioException error, int captured) async {
    if (captured != auth.sessionVersion) return false;
    if (const {
      'AUTH401_2',
      'AUTH401_3',
      'AUTH401_4',
    }.contains(apiErrorCode(error))) {
      await auth.expireSession();
      return true;
    }
    return false;
  }
}
