import 'package:digital_bank/shared/error/result.dart';
import 'package:digital_bank/shared/read.dart';

import '../entities/account.dart';

abstract interface class AccountsRepository {
  Future<Result<Read<List<Account>>>> fetchAccounts();
}
