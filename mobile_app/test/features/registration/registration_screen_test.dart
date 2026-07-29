import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_app/core/network/api_exceptions.dart';
import 'package:mobile_app/core/providers.dart';
import 'package:mobile_app/core/services/fcm_service.dart';
import 'package:mobile_app/core/storage/local_storage_service.dart';
import 'package:mobile_app/features/registration/controller/registration_controller.dart';
import 'package:mobile_app/features/registration/data/registration_repository.dart';
import 'package:mobile_app/features/registration/presentation/registration_screen.dart';

class _MockRegistrationRepository extends Mock implements RegistrationRepository {}

class _MockFcmService extends Mock implements FcmService {}

class _MockLocalStorageService extends Mock implements LocalStorageService {}

void main() {
  late _MockRegistrationRepository repository;
  late _MockFcmService fcmService;
  late _MockLocalStorageService storage;

  setUp(() {
    repository = _MockRegistrationRepository();
    fcmService = _MockFcmService();
    storage = _MockLocalStorageService();
    when(() => fcmService.getToken()).thenAnswer((_) async => 'test-token');
    when(() => storage.saveCode(any())).thenAnswer((_) async {});
  });

  Widget buildTestWidget() {
    return ProviderScope(
      overrides: [
        registrationRepositoryProvider.overrideWithValue(repository),
        fcmServiceProvider.overrideWithValue(fcmService),
        localStorageServiceProvider.overrideWithValue(storage),
      ],
      child: const MaterialApp(home: RegistrationScreen()),
    );
  }

  testWidgets('shows inline error when the code is not found', (tester) async {
    when(() => repository.register(any(), any()))
        .thenThrow(const CodeNotFoundException());

    await tester.pumpWidget(buildTestWidget());

    await tester.enterText(find.byType(TextFormField), '1234');
    await tester.tap(find.text('Continue'));
    await tester.pump(); // start loading
    await tester.pump(); // resolve future

    expect(find.text('Code not found, please check and try again'), findsOneWidget);
  });

  testWidgets('submits and stores code on success', (tester) async {
    when(() => repository.register(any(), any())).thenAnswer((_) async {});

    await tester.pumpWidget(buildTestWidget());

    await tester.enterText(find.byType(TextFormField), '1001');
    await tester.tap(find.text('Continue'));
    await tester.pump();
    await tester.pump();

    verify(() => storage.saveCode('1001')).called(1);
  });
}
