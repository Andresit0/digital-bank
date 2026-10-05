import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/storage_providers.dart';
import '../domain/repositories/onboarding_repository.dart';
import '../infrastructure/datasources/onboarding_local_data_source.dart';
import '../infrastructure/repositories/onboarding_repository_impl.dart';

final onboardingLocalDataSourceProvider = Provider<OnboardingLocalDataSource>(
  (ref) => OnboardingLocalDataSourceImpl(ref.watch(keyValueStoreProvider)),
);

final onboardingRepositoryProvider = Provider<OnboardingRepository>(
  (ref) =>
      OnboardingRepositoryImpl(ref.watch(onboardingLocalDataSourceProvider)),
);
