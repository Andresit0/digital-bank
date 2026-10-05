import 'package:digital_bank/core/services/observability/observability_provider.dart';
import 'package:digital_bank/core/session/session_providers.dart';
import 'package:digital_bank/shared/error/app_error.dart';
import 'package:digital_bank/shared/observability/observability_event.dart';
import 'package:digital_bank/shared/observability/observability_severity.dart';
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
        ref.read(sessionManagerProvider).setToken(session.accessToken);
        state = AuthAuthenticated(session);
      },
      failure: (error) {
        ref.read(observabilityProvider).report(_loginFailedEvent(error));
        state = AuthFailure(error);
      },
    );
  }

  void logout() {
    ref.read(sessionManagerProvider).clear();
    state = const AuthUnauthenticated();
    ref
        .read(observabilityProvider)
        .report(
          const ObservabilityEvent(
            name: 'auth_logout',
            severity: ObservabilitySeverity.info,
          ),
        );
  }

  ObservabilityEvent _loginFailedEvent(AppError error) {
    final metadata = <String, Object?>{
      'errorType': error.runtimeType.toString(),
    };
    if (error is ApiError && error.statusCode != null) {
      metadata['statusCode'] = error.statusCode;
    }
    return ObservabilityEvent(
      name: 'auth_login_failed',
      severity: ObservabilitySeverity.warning,
      metadata: metadata,
    );
  }
}
