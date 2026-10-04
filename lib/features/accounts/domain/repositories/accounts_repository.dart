import '../entities/account.dart';

abstract interface class AccountsRepository {
  Future<List<Account>> fetchAccounts();
}
