import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../accounts_state.dart';
import '../notifiers/accounts_notifier.dart';
import '../widgets/account_card.dart';

class AccountsScreen extends ConsumerStatefulWidget {
  const AccountsScreen({super.key});

  @override
  ConsumerState<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends ConsumerState<AccountsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(accountsProvider.notifier).load());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(accountsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Accounts')),
      body: switch (state) {
        AccountsInitial() || AccountsLoading() => const Center(
          key: Key('accounts_loading'),
          child: CircularProgressIndicator(),
        ),
        AccountsEmpty() => const Center(
          key: Key('accounts_empty'),
          child: Text('No accounts available'),
        ),
        AccountsFailure() => const Center(
          key: Key('accounts_error'),
          child: Text('Something went wrong. Please try again.'),
        ),
        AccountsLoaded(:final accounts) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            for (final account in accounts) AccountCard(account: account),
          ],
        ),
      },
    );
  }
}
