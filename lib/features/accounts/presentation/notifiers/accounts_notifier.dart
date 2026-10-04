import 'package:digital_bank/core/services/logging/logging_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../di/accounts_providers.dart';
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

    final result = await ref.read(accountsRepositoryProvider).fetchAccounts();

    result.when(
      success: (accounts) {
        state = accounts.isEmpty
            ? const AccountsEmpty()
            : AccountsLoaded(accounts);
      },
      failure: (error) {
        ref
            .read(loggerProvider)
            .error(
              '[accounts] load failed',
              technicalMessage: error.technicalMessage,
              stackTrace: error.stackTrace,
            );
        state = AccountsFailure(error);
      },
    );
  }
}
