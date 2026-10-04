import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../di/accounts_providers.dart';
import '../../domain/errors/accounts_error.dart';
import '../accounts_state.dart';

final accountsProvider = NotifierProvider<AccountsNotifier, AccountsState>(
  AccountsNotifier.new,
);

class AccountsNotifier extends Notifier<AccountsState> {
  @override
  AccountsState build() => const AccountsInitial();

  Future<void> load() async {
    if (state is AccountsLoading) {
      return;
    }

    state = const AccountsLoading();

    try {
      final accounts = await ref
          .read(accountsRepositoryProvider)
          .fetchAccounts();
      state = accounts.isEmpty
          ? const AccountsEmpty()
          : AccountsLoaded(accounts);
    } on AccountsError catch (error) {
      state = AccountsFailure(error);
    }
  }
}
