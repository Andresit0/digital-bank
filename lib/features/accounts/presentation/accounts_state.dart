import 'package:digital_bank/shared/error/app_error.dart';

import '../domain/entities/account.dart';

sealed class AccountsState {
  const AccountsState();
}

final class AccountsInitial extends AccountsState {
  const AccountsInitial();
}

final class AccountsLoading extends AccountsState {
  const AccountsLoading();
}

final class AccountsLoaded extends AccountsState {
  const AccountsLoaded(this.accounts);

  final List<Account> accounts;
}

final class AccountsStale extends AccountsState {
  const AccountsStale(this.accounts);

  final List<Account> accounts;
}

final class AccountsEmpty extends AccountsState {
  const AccountsEmpty();
}

final class AccountsFailure extends AccountsState {
  const AccountsFailure(this.error);

  final AppError error;
}
