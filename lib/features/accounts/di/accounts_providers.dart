import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/network_providers.dart';
import '../domain/repositories/accounts_repository.dart';
import '../infrastructure/datasources/accounts_remote_data_source.dart';
import '../infrastructure/repositories/accounts_repository_impl.dart';

final accountsRemoteDataSourceProvider = Provider<AccountsRemoteDataSource>(
  (ref) => AccountsRemoteDataSourceImpl(ref.watch(httpClientProvider)),
);

final accountsRepositoryProvider = Provider<AccountsRepository>(
  (ref) => AccountsRepositoryImpl(ref.watch(accountsRemoteDataSourceProvider)),
);
