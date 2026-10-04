import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../router/app_router.dart';
import '../../../features/auth/presentation/auth_state.dart';
import '../../../features/auth/presentation/notifiers/auth_notifier.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final listenable = AuthRouterRefreshListenable(ref);
  ref.onDispose(listenable.dispose);
  return createAppRouter(
    refreshListenable: listenable,
    redirect: (location) => _resolveRedirect(
      isAuthenticated: listenable.isAuthenticated,
      location: location,
    ),
  );
});

String? _resolveRedirect({
  required bool isAuthenticated,
  required String location,
}) {
  final isEntry =
      location == AppRoute.bootstrap.path || location == AppRoute.login.path;

  if (!isAuthenticated) {
    return location == AppRoute.login.path ? null : AppRoute.login.path;
  }

  return isEntry ? AppRoute.home.path : null;
}

class AuthRouterRefreshListenable extends ChangeNotifier {
  AuthRouterRefreshListenable(Ref ref) {
    _isAuthenticated = _resolve(ref.read(authProvider));
    _subscription = ref.listen<AuthState>(authProvider, (_, next) {
      _isAuthenticated = _resolve(next);
      notifyListeners();
    });
  }

  late bool _isAuthenticated;
  ProviderSubscription<AuthState>? _subscription;

  bool get isAuthenticated => _isAuthenticated;

  static bool _resolve(AuthState state) => state is AuthAuthenticated;

  @override
  void dispose() {
    _subscription?.close();
    super.dispose();
  }
}
