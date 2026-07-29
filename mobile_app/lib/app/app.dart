import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/providers.dart';
import '../core/services/deep_link_service.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/notifications/controller/notifications_controller.dart';
import '../features/notifications/presentation/notifications_screen.dart';
import '../features/registration/presentation/registration_screen.dart';
import '../features/registration/controller/registration_controller.dart';
import 'app_startup.dart';
import 'theme.dart';

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initListeners());
  }

  Future<void> _initListeners() async {
    final fcmService = ref.read(fcmServiceProvider);
    await fcmService.requestPermission();

    fcmService.onForegroundMessage((_) {
      ref.read(notificationsControllerProvider.notifier).refresh();
    });

    fcmService.onMessageOpenedApp((_) => _openNotifications());

    final initialMessage = await fcmService.getInitialMessage();
    if (initialMessage != null) {
      _openNotifications();
    }

    // Warm deep link: app already running (foreground or background) when
    // the link was opened. Routed through the same registration flow as
    // manual/cold-start entry so there's a single source of truth.
    ref.read(deepLinkServiceProvider).linkStream.listen((uri) {
      final code = DeepLinkService.extractCode(uri);
      if (code == null) return;
      _navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (_) => RegistrationScreen(initialCode: code, autoSubmit: true),
        ),
      );
    });

    // Auto-sync device FCM token with backend on every app startup
    try {
      final storedCode = await ref.read(localStorageServiceProvider).getCode();
      if (storedCode != null) {
        final token = await fcmService.getToken();
        if (token != null) {
          await ref.read(registrationRepositoryProvider).register(storedCode, token);
          debugPrint('FCM Token synced on startup: $token');
        }
      }
    } catch (e) {
      debugPrint('FCM Token sync failed on startup: $e');
    }
  }

  void _openNotifications() {
    _navigatorKey.currentState?.push(
      MaterialPageRoute(builder: (_) => const NotificationsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final startup = ref.watch(appStartupProvider);

    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: 'متابعة الطالب',
      theme: appTheme,
      home: startup.when(
        loading: () => const _SplashScreen(),
        error: (_, __) => const RegistrationScreen(),
        data: (result) => switch (result) {
          AppStartupHome() => const HomeScreen(),
          AppStartupDeepLink(code: final code) =>
            RegistrationScreen(initialCode: code, autoSubmit: true),
          AppStartupRegistration() => const RegistrationScreen(),
        },
      ),
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
