import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/interfaces/i_logger.dart';
import 'dev_logger.dart';

final loggerProvider = Provider<ILogger>((ref) => const DevLogger());
