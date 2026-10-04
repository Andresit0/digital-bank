import 'package:digital_bank/core/services/logging/logging_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../di/auth_providers.dart';
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

    final result = await ref
        .read(authRepositoryProvider)
        .login(email: email, password: password);

    result.when(
      success: (session) {
        state = AuthAuthenticated(session);
      },
      failure: (error) {
        ref
            .read(loggerProvider)
            .error(
              '[auth] authentication failed',
              technicalMessage: error.technicalMessage,
              stackTrace: error.stackTrace,
            );
        state = AuthFailure(error);
      },
    );
  }

  void logout() {
    state = const AuthUnauthenticated();
  }
}
