import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_app/core/providers.dart';
import 'package:mobile_app/core/storage/local_storage_service.dart';
import 'package:mobile_app/features/notifications/controller/notifications_controller.dart';
import 'package:mobile_app/features/notifications/data/models/notification_model.dart';
import 'package:mobile_app/features/notifications/data/notifications_repository.dart';

class _MockNotificationsRepository extends Mock implements NotificationsRepository {}

class _MockLocalStorageService extends Mock implements LocalStorageService {}

void main() {
  late _MockNotificationsRepository repository;
  late _MockLocalStorageService storage;
  late ProviderContainer container;

  final sample = NotificationModel(
    id: 'n1',
    message: 'Hello',
    isRead: false,
    sentAt: DateTime(2026, 1, 1),
    readAt: null,
    deliveryStatus: 'sent',
  );

  setUp(() {
    repository = _MockNotificationsRepository();
    storage = _MockLocalStorageService();
    when(() => storage.getCode()).thenAnswer((_) async => '1001');
    when(() => repository.fetchHistory(any())).thenAnswer((_) async => [sample]);

    container = ProviderContainer(
      overrides: [
        notificationsRepositoryProvider.overrideWithValue(repository),
        localStorageServiceProvider.overrideWithValue(storage),
      ],
    );
  });

  tearDown(() => container.dispose());

  test('markAsRead rolls back the optimistic update on failure', () async {
    when(() => repository.markRead(any())).thenThrow(Exception('network error'));

    final controller = container.read(notificationsControllerProvider.notifier);
    await controller.loadHistory();

    await controller.markAsRead('n1');

    final state = container.read(notificationsControllerProvider).value!;
    expect(state.single.isRead, isFalse);
  });

  test('markAsRead keeps the optimistic update on success', () async {
    when(() => repository.markRead(any())).thenAnswer((_) async {});

    final controller = container.read(notificationsControllerProvider.notifier);
    await controller.loadHistory();

    await controller.markAsRead('n1');

    final state = container.read(notificationsControllerProvider).value!;
    expect(state.single.isRead, isTrue);
  });
}
