import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/providers.dart';

sealed class AppStartupResult {
  const AppStartupResult();
}

class AppStartupHome extends AppStartupResult {
  const AppStartupHome();
}

class AppStartupDeepLink extends AppStartupResult {
  final String code;
  const AppStartupDeepLink(this.code);
}

class AppStartupRegistration extends AppStartupResult {
  const AppStartupRegistration();
}

/// Overridden in main() with the code extracted from a cold-start deep link
/// (captured via `getInitialLink()` before the first frame), or left null
/// if the app was launched normally.
final initialDeepLinkCodeProvider = Provider<String?>((ref) => null);

/// Single decision point evaluated once at startup, combining "is there
/// already a stored code" with "did we cold-start from a deep link" so the
/// two signals can't race each other into contradictory navigation.
final appStartupProvider = FutureProvider<AppStartupResult>((ref) async {
  final storedCode = await ref.watch(localStorageServiceProvider).getCode();
  if (storedCode != null) {
    return const AppStartupHome();
  }

  final pendingCode = ref.watch(initialDeepLinkCodeProvider);
  if (pendingCode != null) {
    return AppStartupDeepLink(pendingCode);
  }

  return const AppStartupRegistration();
});
