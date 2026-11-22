import 'package:flutter/foundation.dart';

mixin SafeNotify on ChangeNotifier {
  bool _notifyDisposed = false;
  bool get isAlive => !_notifyDisposed;

  void notifyIfAlive() {
    if (!_notifyDisposed) notifyListeners();
  }

  @override
  void dispose() {
    _notifyDisposed = true;
    super.dispose();
  }
}
