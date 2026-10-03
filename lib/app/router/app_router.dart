import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

enum AppRoute {
  bootstrap(path: '/', name: 'bootstrap'),
  home(path: '/home', name: 'home'),
  accounts(path: '/accounts', name: 'accounts'),
  transactions(path: '/transactions', name: 'transactions');

  const AppRoute({required this.path, required this.name});

  final String path;
  final String name;
}

final GoRouter appRouter = createAppRouter();

GoRouter createAppRouter() {
  return GoRouter(
    initialLocation: AppRoute.bootstrap.path,
    routes: [
      GoRoute(
        path: AppRoute.bootstrap.path,
        name: AppRoute.bootstrap.name,
        builder: (_, _) =>
            const RouterPlaceholderScreen(title: 'Application Bootstrap'),
      ),
      GoRoute(
        path: AppRoute.home.path,
        name: AppRoute.home.name,
        builder: (_, _) => const RouterPlaceholderScreen(title: 'Home'),
      ),
      GoRoute(
        path: AppRoute.accounts.path,
        name: AppRoute.accounts.name,
        builder: (_, _) => const RouterPlaceholderScreen(title: 'Accounts'),
      ),
      GoRoute(
        path: AppRoute.transactions.path,
        name: AppRoute.transactions.name,
        builder: (_, _) =>
            const RouterPlaceholderScreen(title: 'Transactions'),
      ),
    ],
  );
}

class RouterPlaceholderScreen extends StatelessWidget {
  const RouterPlaceholderScreen({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text(title)));
  }
}
