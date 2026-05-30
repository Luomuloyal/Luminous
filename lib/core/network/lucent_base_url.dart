abstract final class LucentBaseUrl {
  static const String defineKey = 'LUCENT_BASE_URL';
  static const String _fallback = 'http://127.0.0.1:3000';

  static String get value {
    const raw = String.fromEnvironment(defineKey, defaultValue: _fallback);
    final normalized = raw.trim();
    return normalized.isEmpty ? _fallback : normalized;
  }
}
