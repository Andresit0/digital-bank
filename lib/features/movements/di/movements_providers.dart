import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/network_providers.dart';
import '../domain/repositories/movements_repository.dart';
import '../infrastructure/datasources/movements_remote_data_source.dart';
import '../infrastructure/repositories/movements_repository_impl.dart';

final movementsRemoteDataSourceProvider = Provider<MovementsRemoteDataSource>(
  (ref) => MovementsRemoteDataSourceImpl(ref.watch(httpClientProvider)),
);

final movementsRepositoryProvider = Provider<MovementsRepository>(
  (ref) =>
      MovementsRepositoryImpl(ref.watch(movementsRemoteDataSourceProvider)),
);
