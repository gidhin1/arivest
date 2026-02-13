import 'package:shared_preferences/shared_preferences.dart';

class StoredSession {
  const StoredSession({
    required this.token,
    required this.expiresAt,
    this.onboardingRequired = false,
  });

  final String token;
  final DateTime expiresAt;
  final bool onboardingRequired;
}

abstract class SessionStore {
  Future<StoredSession?> read();
  Future<void> save(StoredSession session);
  Future<void> clear();
}

class SharedPreferencesSessionStore implements SessionStore {
  static const String _tokenKey = 'auth_session_token';
  static const String _expiryKey = 'auth_session_expiry';
  static const String _onboardingKey = 'auth_onboarding_required';

  @override
  Future<StoredSession?> read() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    final expiryRaw = prefs.getString(_expiryKey);
    if (token == null || token.isEmpty || expiryRaw == null) {
      return null;
    }
    final expiry = DateTime.tryParse(expiryRaw);
    if (expiry == null) {
      await clear();
      return null;
    }
    final onboardingRequired = prefs.getBool(_onboardingKey) ?? false;
    return StoredSession(
      token: token,
      expiresAt: expiry.toUtc(),
      onboardingRequired: onboardingRequired,
    );
  }

  @override
  Future<void> save(StoredSession session) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, session.token);
    await prefs.setString(
      _expiryKey,
      session.expiresAt.toUtc().toIso8601String(),
    );
    await prefs.setBool(_onboardingKey, session.onboardingRequired);
  }

  @override
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_expiryKey);
    await prefs.remove(_onboardingKey);
  }
}
