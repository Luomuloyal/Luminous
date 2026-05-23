import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/features/auth/data/user_session_store.dart';
import 'package:luminous/stores/providers/shared_preferences_provider.dart';
import 'package:luminous/viewmodels/auth.dart';

class UserSessionState {
  const UserSessionState({required this.ready, this.user});

  const UserSessionState.pending() : ready = false, user = null;

  final bool ready;
  final UserSafe? user;

  bool get isLoggedIn => user?.hasData ?? false;
}

class UserSessionNotifier extends Notifier<UserSessionState> {
  UserSessionStore get _store => ref.read(userSessionStoreProvider);

  @override
  UserSessionState build() {
    return const UserSessionState(ready: true);
  }

  Future<UserSafe?> restore() async {
    state = const UserSessionState.pending();
    final restoredUser = await _store.restoreUser();
    state = UserSessionState(ready: true, user: restoredUser);
    return restoredUser;
  }

  Future<void> setUser(UserSafe user) async {
    state = UserSessionState(ready: true, user: user);
    await _store.persistUser(user);
  }

  Future<void> clear() async {
    state = const UserSessionState(ready: true);
    await _store.clearUser();
  }
}

final userSessionStoreProvider = Provider<UserSessionStore>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return UserSessionStore.fromPreferences(prefs);
});

final userSessionProvider =
    NotifierProvider<UserSessionNotifier, UserSessionState>(() {
      return UserSessionNotifier();
    });
