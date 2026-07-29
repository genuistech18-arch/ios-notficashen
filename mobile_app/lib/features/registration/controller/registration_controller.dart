import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers.dart';
import '../data/registration_repository.dart';
import 'account_controller.dart';

/// Used when this device can't obtain a real FCM token (e.g. Firebase isn't
/// configured yet) so registration can still be tested end-to-end; the
/// backend already degrades FCM sends to this token gracefully.
const _noFcmTokenPlaceholder = 'no-fcm-token-available';

final registrationRepositoryProvider = Provider<RegistrationRepository>(
  (ref) => RegistrationRepository(ref.watch(apiClientProvider)),
);

final registrationControllerProvider =
    StateNotifierProvider<RegistrationController, AsyncValue<void>>(
  (ref) => RegistrationController(ref),
);

/// Single entry point for linking a code to this device — used by both the
/// manual entry screen and the deep-link auto-registration flow, so neither
/// path can drift out of sync with the other.
class RegistrationController extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  RegistrationController(this._ref) : super(const AsyncValue.data(null));

  Future<bool> submit(String code) async {
    state = const AsyncValue.loading();
    try {
      final token = await _ref.read(fcmServiceProvider).getToken();

      await _ref
          .read(registrationRepositoryProvider)
          .register(code, token ?? _noFcmTokenPlaceholder);
      await _ref.read(accountControllerProvider.notifier).addCode(code);

      state = const AsyncValue.data(null);
      return true;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return false;
    }
  }
}
