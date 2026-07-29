import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers.dart';
import '../../notifications/controller/notifications_controller.dart';

class AccountState {
  final String? activeCode;
  final List<String> registeredCodes;

  AccountState({this.activeCode, this.registeredCodes = const []});

  AccountState copyWith({
    String? activeCode,
    List<String>? registeredCodes,
  }) {
    return AccountState(
      activeCode: activeCode ?? this.activeCode,
      registeredCodes: registeredCodes ?? this.registeredCodes,
    );
  }
}

final accountControllerProvider =
    StateNotifierProvider<AccountController, AccountState>(
  (ref) => AccountController(ref),
);

class AccountController extends StateNotifier<AccountState> {
  final Ref _ref;

  AccountController(this._ref) : super(AccountState()) {
    loadAccounts();
  }

  Future<void> loadAccounts() async {
    final storage = _ref.read(localStorageServiceProvider);
    final active = await storage.getCode();
    final all = await storage.getRegisteredCodes();
    state = AccountState(activeCode: active, registeredCodes: all);
  }

  Future<void> switchCode(String code) async {
    final storage = _ref.read(localStorageServiceProvider);
    await storage.setActiveCode(code);
    state = state.copyWith(activeCode: code);
    _ref.read(notificationsControllerProvider.notifier).loadHistory();
  }

  Future<void> removeCode(String code) async {
    final storage = _ref.read(localStorageServiceProvider);
    await storage.removeCode(code);
    await loadAccounts();
    _ref.read(notificationsControllerProvider.notifier).loadHistory();
  }

  Future<void> addCode(String code) async {
    final storage = _ref.read(localStorageServiceProvider);
    await storage.saveCode(code);
    await loadAccounts();
    _ref.read(notificationsControllerProvider.notifier).loadHistory();
  }
}
