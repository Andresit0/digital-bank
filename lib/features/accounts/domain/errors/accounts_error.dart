sealed class AccountsError implements Exception {
  const AccountsError();

  static const AccountsError invalidCredentials = AccountsInvalidCredentials();
  static const AccountsError network = AccountsNetwork();
}

final class AccountsInvalidCredentials extends AccountsError {
  const AccountsInvalidCredentials();
}

final class AccountsNetwork extends AccountsError {
  const AccountsNetwork();
}
