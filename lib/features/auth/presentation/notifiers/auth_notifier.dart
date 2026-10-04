import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../di/auth_providers.dart';
import '../../domain/errors/auth_error.dart';
import '../auth_state.dart';

final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthInitial();

  Future<void> login({required String email, required String password}) async {
    if (state is AuthLoading) {
      return;
    }

    state = const AuthLoading();

    try {
      final session = await ref
          .read(authRepositoryProvider)
          .login(email: email, password: password);
      state = AuthAuthenticated(session);
    } on AuthError catch (error) {
      state = AuthFailure(error);
    }
  }

  void logout() {
    state = const AuthUnauthenticated();
  }
}
