import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/network_providers.dart';
import '../domain/repositories/experience_repository.dart';
import '../infrastructure/datasources/experience_remote_data_source.dart';
import '../infrastructure/repositories/experience_repository_impl.dart';

final experienceRemoteDataSourceProvider = Provider<ExperienceRemoteDataSource>(
  (ref) => ExperienceRemoteDataSourceImpl(ref.watch(httpClientProvider)),
);

final experienceRepositoryProvider = Provider<ExperienceRepository>(
  (ref) =>
      ExperienceRepositoryImpl(ref.watch(experienceRemoteDataSourceProvider)),
);
