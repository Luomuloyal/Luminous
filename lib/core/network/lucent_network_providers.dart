import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/network/lucent_api.dart';

final lucentBaseUrlProvider = Provider<String>((ref) {
  return LucentBaseUrl.value;
});

final lucentSessionStoreProvider = Provider<LucentSessionStore>((ref) {
  return const SharedPrefsLucentSessionStore();
});

final lucentDioClientProvider = Provider<LucentDioClient>((ref) {
  final client = LucentDioClient(
    baseUrl: ref.watch(lucentBaseUrlProvider),
    sessionStore: ref.watch(lucentSessionStoreProvider),
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
