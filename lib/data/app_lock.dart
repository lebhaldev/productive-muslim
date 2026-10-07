import 'package:local_auth/local_auth.dart';

/// The phone's own fingerprint, face, PIN or pattern; faked in tests.
class AppLock {
  AppLock([LocalAuthentication? auth]) : _auth = auth ?? LocalAuthentication();
  final LocalAuthentication _auth;

  /// False when the phone has no screen lock set up.
  Future<bool> available() async {
    try {
      return await _auth.isDeviceSupported();
    } catch (_) {
      return false;
    }
  }

  Future<bool> unlock(String reason) async {
    try {
      return await _auth.authenticate(localizedReason: reason);
    } catch (_) {
      return false;
    }
  }
}
