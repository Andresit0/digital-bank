import 'package:shared_preferences/shared_preferences.dart';

const String onboardingCompletedKey = 'onboarding_completed';

Future<void> seedOnboardingCompleted() {
  return SharedPreferencesAsync().setBool(onboardingCompletedKey, true);
}

Future<void> clearOnboardingCompleted() {
  return SharedPreferencesAsync().remove(onboardingCompletedKey);
}

Future<bool?> onboardingCompleted() {
  return SharedPreferencesAsync().getBool(onboardingCompletedKey);
}
