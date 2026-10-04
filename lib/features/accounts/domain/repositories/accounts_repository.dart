import 'package:digital_bank/shared/error/result.dart';

import '../entities/account.dart';

abstract interface class AccountsRepository {
  Future<Result<List<Account>>> fetchAccounts();
}
