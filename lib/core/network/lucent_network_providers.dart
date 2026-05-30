import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/i18n/app_locale.dart';
import 'package:luminous/core/network/lucent_api.dart';

final lucentBaseUrlProvider = Provider<String>((ref) {
  return LucentBaseUrl.value;
});

class AppLocaleNotifier extends Notifier<AppLocale> {
  @override
  AppLocale build() => AppLocale.en;

  void setLocale(AppLocale locale) {
    state = locale;
  }
}

final appLocaleProvider = NotifierProvider<AppLocaleNotifier, AppLocale>(
  AppLocaleNotifier.new,
);

final lucentSessionStoreProvider = Provider<LucentSessionStore>((ref) {
  return const SecureLucentSessionStore();
});

final lucentDioClientProvider = Provider<LucentDioClient>((ref) {
  final client = LucentDioClient(
    baseUrl: ref.watch(lucentBaseUrlProvider),
    sessionStore: ref.watch(lucentSessionStoreProvider),
    localeResolver: () => ref.read(appLocaleProvider).acceptLanguage,
  );
  ref.onDispose(client.dispose);
  return client;
});

final lucentAuthApiProvider = Provider<AuthApi>((ref) {
  return ref.watch(lucentDioClientProvider).authApi;
});

final lucentAppApiProvider = Provider<AppApi>((ref) {
  return ref.watch(lucentDioClientProvider).appApi;
});
