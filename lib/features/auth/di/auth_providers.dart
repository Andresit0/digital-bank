import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/network_providers.dart';
import '../domain/repositories/auth_repository.dart';
import '../infrastructure/datasources/auth_remote_data_source.dart';
import '../infrastructure/repositories/auth_repository_impl.dart';

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>(
  (ref) => AuthRemoteDataSourceImpl(ref.watch(httpClientProvider)),
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(ref.watch(authRemoteDataSourceProvider)),
);
