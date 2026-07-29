import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers.dart';
import '../data/models/notification_model.dart';
import '../data/notifications_repository.dart';

final notificationsRepositoryProvider = Provider<NotificationsRepository>(
  (ref) => NotificationsRepository(ref.watch(apiClientProvider)),
);

final notificationsControllerProvider = StateNotifierProvider<
    NotificationsController, AsyncValue<List<NotificationModel>>>(
  (ref) => NotificationsController(ref),
);

class NotificationsController
    extends StateNotifier<AsyncValue<List<NotificationModel>>> {
  final Ref _ref;
  Timer? _pollingTimer;
  final Set<String> _shownNotificationIds = {};
  bool _isInitialLoad = true;

  NotificationsController(this._ref) : super(const AsyncValue.loading()) {
    loadHistory();
    // Start periodic polling every 5 seconds for new notifications
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      loadHistory(silent: true);
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> loadHistory({bool silent = false}) async {
    if (!silent) {
      state = const AsyncValue.loading();
    }
    try {
      final code = await _ref.read(localStorageServiceProvider).getCode();
      if (code == null) {
        state = const AsyncValue.data([]);
        return;
      }
      final history =
          await _ref.read(notificationsRepositoryProvider).fetchHistory(code);

      // Check for new unread notifications and pop them up in the Android Status Bar
      for (final item in history) {
        if (!item.isRead && !_shownNotificationIds.contains(item.id)) {
          _shownNotificationIds.add(item.id);
          // Don't show system banner for old notifications on initial app startup,
          // only for newly arriving notifications during the session.
          if (!_isInitialLoad) {
            _ref.read(fcmServiceProvider).showDirectNotification(
                  title: 'متابعة الطالب',
                  body: item.message,
                );
          }
        }
      }

      _isInitialLoad = false;
      state = AsyncValue.data(history);
    } catch (error, stackTrace) {
      if (!silent) {
        state = AsyncValue.error(error, stackTrace);
      }
    }
  }

  Future<void> refresh() => loadHistory();

  Future<void> markAsRead(String id) async {
    final current = state.value;
    if (current == null) return;

    final index = current.indexWhere((n) => n.id == id);
    if (index == -1 || current[index].isRead) return;

    final optimistic = [...current];
    optimistic[index] = optimistic[index].copyWith(
      isRead: true,
      readAt: DateTime.now(),
    );
    state = AsyncValue.data(optimistic);

    try {
      await _ref.read(notificationsRepositoryProvider).markRead(id);
    } catch (_) {
      state = AsyncValue.data(current);
    }
  }
}
