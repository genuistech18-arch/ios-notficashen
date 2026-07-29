import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';
import 'app/app_startup.dart';
import 'core/services/deep_link_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    debugPrint('Firebase initialized successfully in main.dart');
  } catch (e, st) {
    debugPrint('Firebase initialization failed: $e\n$st');
  }

  // Cold-start deep link must be captured before the first frame, otherwise
  // it can be missed by the time the widget tree builds.
  String? initialDeepLinkCode;
  try {
    final initialUri = await DeepLinkService().getInitialLink();
    if (initialUri != null) {
      initialDeepLinkCode = DeepLinkService.extractCode(initialUri);
    }
  } catch (_) {}

  runApp(
    ProviderScope(
      overrides: [
        initialDeepLinkCodeProvider.overrideWithValue(initialDeepLinkCode),
      ],
      child: const App(),
    ),
  );
}
