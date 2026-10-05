import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/accounts/presentation/screens/accounts_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/movements/domain/entities/movement.dart';
import '../../features/movements/presentation/screens/movement_detail_screen.dart';
import '../../features/movements/presentation/screens/movements_screen.dart';

enum AppRoute {
  bootstrap(path: '/', name: 'bootstrap'),
  login(path: '/login', name: 'login'),
  home(path: '/home', name: 'home'),
  accounts(path: '/accounts', name: 'accounts'),
  movements(path: '/movements', name: 'movements');

  const AppRoute({required this.path, required this.name});

  final String path;
  final String name;
}

GoRouter createAppRouter({
  String initialLocation = '/',
  Listenable? refreshListenable,
  AuthRedirect? redirect,
}) {
  return GoRouter(
    initialLocation: initialLocation,
    refreshListenable: refreshListenable,
    redirect: (context, state) => redirect?.call(state.matchedLocation),
    routes: [
      GoRoute(
        path: AppRoute.bootstrap.path,
        name: AppRoute.bootstrap.name,
        builder: (_, _) =>
            const RouterPlaceholderScreen(title: 'Application Bootstrap'),
      ),
      GoRoute(
        path: AppRoute.login.path,
        name: AppRoute.login.name,
        builder: (_, _) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoute.home.path,
        name: AppRoute.home.name,
        builder: (_, _) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoute.accounts.path,
        name: AppRoute.accounts.name,
        builder: (_, state) => AccountsScreen(
          selectForMovements:
              state.uri.queryParameters['intent'] == 'movements',
        ),
      ),
      GoRoute(
        path: AppRoute.movements.path,
        name: AppRoute.movements.name,
        builder: (_, state) =>
            MovementsScreen(accountId: state.uri.queryParameters['accountId']),
        routes: [
          GoRoute(
            path: ':id',
            name: 'movementDetail',
            builder: (_, state) =>
                MovementDetailScreen(movement: state.extra as Movement?),
          ),
        ],
      ),
    ],
  );
}

typedef AuthRedirect = String? Function(String location);

class RouterPlaceholderScreen extends StatelessWidget {
  const RouterPlaceholderScreen({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text(title)));
  }
}
