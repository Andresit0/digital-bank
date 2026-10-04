import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'session_manager.dart';

final sessionManagerProvider = Provider<SessionManager>(
  (ref) => SessionManager(),
);
