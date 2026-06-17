import 'package:flutter/widgets.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Owns app-lock state: whether Face ID is required, the idle timeout, and
/// the last-active timestamp. Settings persist via SharedPreferences.
/// Swappable later; UI just reads/writes through this service.
class AppLockService {
  AppLockService._();
  static final AppLockService instance = AppLockService._();

  static const String _kEnabled = 'lock_enabled';
  static const String _kTimeout = 'lock_timeout_minutes';

  final LocalAuthentication _auth = LocalAuthentication();

  bool _enabled = false;
  int _timeoutMinutes = 5; // default per spec
  DateTime _lastActive = DateTime.now();

  bool get isEnabled => _enabled;
  int get timeoutMinutes => _timeoutMinutes;

  /// Load saved settings at startup.
  Future<void> load() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _enabled = prefs.getBool(_kEnabled) ?? false;
    _timeoutMinutes = prefs.getInt(_kTimeout) ?? 5;
    _lastActive = DateTime.now();
  }

  Future<void> setEnabled(bool value) async {
    _enabled = value;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kEnabled, value);
    _lastActive = DateTime.now();
  }

  Future<void> setTimeout(int minutes) async {
    _timeoutMinutes = minutes;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kTimeout, minutes);
  }

  /// Call on any user activity to reset the idle timer.
  void recordActivity() => _lastActive = DateTime.now();

  /// Whether the app should lock right now.
  /// Locks only when: enabled AND idle beyond timeout AND keyboard not open.
  bool shouldLock(BuildContext context) {
    if (!_enabled) return false;
    final bool keyboardOpen =
        MediaQuery.of(context).viewInsets.bottom > 0;
    if (keyboardOpen) return false; // never lock mid-typing
    final Duration idle = DateTime.now().difference(_lastActive);
    return idle.inMinutes >= _timeoutMinutes;
  }

  /// Returns true if Face ID / biometric (or device passcode) succeeds.
  Future<bool> authenticate() async {
    try {
      final bool canCheck =
          await _auth.canCheckBiometrics || await _auth.isDeviceSupported();
      if (!canCheck) return true; // no biometrics available: do not lock out
      return await _auth.authenticate(
        localizedReason: 'Unlock 1SocialSuite',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );
    } catch (_) {
      // On error, fail open so a user is never permanently locked out in v1.
      return true;
    }
  }
}
