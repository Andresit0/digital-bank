import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../router/app_router.dart';
import '../../../features/auth/presentation/auth_state.dart';
import '../../../features/auth/presentation/notifiers/auth_notifier.dart';
import '../../../features/onboarding/presentation/notifiers/onboarding_notifier.dart';
import '../../../features/onboarding/presentation/onboarding_state.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final listenable = AppRouterRefreshListenable(ref);
  ref.onDispose(listenable.dispose);
  return createAppRouter(
    refreshListenable: listenable,
    redirect: (location) => _resolveRedirect(
      isAuthenticated: listenable.isAuthenticated,
      onboardingResolved: listenable.onboardingResolved,
      onboardingCompleted: listenable.onboardingCompleted,
      location: location,
    ),
  );
});

String? _resolveRedirect({
  required bool isAuthenticated,
  required bool onboardingResolved,
  required bool onboardingCompleted,
  required String location,
}) {
  if (!onboardingResolved) {
    return location == AppRoute.bootstrap.path ? null : AppRoute.bootstrap.path;
  }

  if (!onboardingCompleted) {
    return location == AppRoute.onboarding.path
        ? null
        : AppRoute.onboarding.path;
  }

  final isEntry =
      location == AppRoute.bootstrap.path ||
      location == AppRoute.onboarding.path ||
      location == AppRoute.login.path;

  if (!isAuthenticated) {
    return location == AppRoute.login.path ? null : AppRoute.login.path;
  }

  return isEntry ? AppRoute.home.path : null;
}

class AppRouterRefreshListenable extends ChangeNotifier {
  AppRouterRefreshListenable(Ref ref) {
    _isAuthenticated = _resolveAuth(ref.read(authProvider));
    _onboardingState = ref.read(onboardingProvider);

    _authSubscription = ref.listen<AuthState>(authProvider, (_, next) {
      _isAuthenticated = _resolveAuth(next);
      notifyListeners();
    });

    _onboardingSubscription = ref.listen<OnboardingState>(onboardingProvider, (
      _,
      next,
    ) {
      _onboardingState = next;
      notifyListeners();
    });
  }

  late bool _isAuthenticated;
  late OnboardingState _onboardingState;
  ProviderSubscription<AuthState>? _authSubscription;
  ProviderSubscription<OnboardingState>? _onboardingSubscription;

  bool get isAuthenticated => _isAuthenticated;

  bool get onboardingResolved => _onboardingState is! OnboardingInitial;

  bool get onboardingCompleted => _onboardingState is OnboardingCompleted;

  static bool _resolveAuth(AuthState state) => state is AuthAuthenticated;

  @override
  void dispose() {
    _authSubscription?.close();
    _onboardingSubscription?.close();
    super.dispose();
  }
}
