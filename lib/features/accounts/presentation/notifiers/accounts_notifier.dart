import 'package:digital_bank/core/services/observability/observability_provider.dart';
import 'package:digital_bank/shared/error/app_error.dart';
import 'package:digital_bank/shared/observability/observability_event.dart';
import 'package:digital_bank/shared/observability/observability_severity.dart';
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
        ref.read(observabilityProvider).report(_loadFailedEvent(error));
        state = AccountsFailure(error);
      },
    );
  }

  ObservabilityEvent _loadFailedEvent(AppError error) {
    final metadata = <String, Object?>{
      'errorType': error.runtimeType.toString(),
    };
    if (error is ApiError && error.statusCode != null) {
      metadata['statusCode'] = error.statusCode;
    }
    return ObservabilityEvent(
      name: 'accounts_load_failed',
      severity: ObservabilitySeverity.warning,
      metadata: metadata,
    );
  }
}
