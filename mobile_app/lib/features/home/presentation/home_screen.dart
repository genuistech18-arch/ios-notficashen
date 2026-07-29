import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../notifications/presentation/notifications_screen.dart';
import '../../registration/controller/account_controller.dart';
import '../../registration/presentation/registration_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late final WebViewController _webViewController;
  int _loadingProgress = 0;
  String? _currentLoadedCode;

  @override
  void initState() {
    super.initState();
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            if (mounted) {
              setState(() {
                _loadingProgress = progress;
              });
            }
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onWebResourceError: (WebResourceError error) {},
        ),
      );
  }

  void _loadStudentUrl(String code) {
    if (_currentLoadedCode == code) return;
    _currentLoadedCode = code;
    final targetUrl = 'https://educenter.genuisweb.com/student?number=$code&code=$code';
    _webViewController.loadRequest(Uri.parse(targetUrl));
  }

  void _showAddCodeDialog(BuildContext context, WidgetRef ref) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const RegistrationScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accountState = ref.watch(accountControllerProvider);
    final accountController = ref.read(accountControllerProvider.notifier);
    final activeCode = accountState.activeCode ?? '';

    if (activeCode.isNotEmpty) {
      _loadStudentUrl(activeCode);
    }

    return Scaffold(
      appBar: AppBar(
        title: PopupMenuButton<String>(
          tooltip: 'إدارة الأكواد والتبديل',
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.qr_code, size: 20),
              const SizedBox(width: 8),
              Text(
                'كود: ${activeCode.isEmpty ? "N/A" : activeCode}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const Icon(Icons.arrow_drop_down),
            ],
          ),
          onSelected: (value) async {
            if (value == 'ADD_NEW') {
              _showAddCodeDialog(context, ref);
            } else if (value.startsWith('REMOVE_')) {
              final codeToRemove = value.replaceFirst('REMOVE_', '');
              await accountController.removeCode(codeToRemove);
              if (context.mounted && (ref.read(accountControllerProvider).registeredCodes.isEmpty)) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const RegistrationScreen()),
                );
              }
            } else {
              await accountController.switchCode(value);
            }
          },
          itemBuilder: (context) {
            final items = <PopupMenuEntry<String>>[];

            items.add(
              const PopupMenuItem<String>(
                enabled: false,
                child: Text(
                  'الأكواد المسجلة (اضغط للتبديل):',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                ),
              ),
            );

            for (final code in accountState.registeredCodes) {
              final isCurrent = code == activeCode;
              items.add(
                PopupMenuItem<String>(
                  value: code,
                  child: Row(
                    children: [
                      Icon(
                        isCurrent ? Icons.check_circle : Icons.radio_button_unchecked,
                        color: isCurrent ? Colors.green : Colors.grey,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          code,
                          style: TextStyle(
                            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                      if (accountState.registeredCodes.length > 1)
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                          onPressed: () {
                            Navigator.of(context).pop();
                            accountController.removeCode(code);
                          },
                        ),
                    ],
                  ),
                ),
              );
            }

            items.add(const PopupMenuDivider());

            items.add(
              const PopupMenuItem<String>(
                value: 'ADD_NEW',
                child: Row(
                  children: [
                    Icon(Icons.add_circle_outline, color: Colors.blue),
                    SizedBox(width: 10),
                    Text('إضافة كود آخر (+)', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            );

            return items;
          },
        ),
        actions: [
          // Refresh Web Page Button
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'تحديث الصفحة',
            onPressed: () => _webViewController.reload(),
          ),
          // Top Notifications Button
          IconButton(
            icon: const Icon(Icons.notifications_active),
            tooltip: 'الإشعارات',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
              );
            },
          ),
          // Options Menu (Logout)
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) async {
              if (value == 'LOGOUT') {
                if (accountState.activeCode != null) {
                  await accountController.removeCode(accountState.activeCode!);
                }
                if (context.mounted) {
                  final remaining = ref.read(accountControllerProvider).registeredCodes;
                  if (remaining.isEmpty) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const RegistrationScreen()),
                    );
                  }
                }
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem<String>(
                value: 'LOGOUT',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text('تسجيل خروج الحساب الحالي'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          if (_loadingProgress > 0 && _loadingProgress < 100)
            LinearProgressIndicator(
              value: _loadingProgress / 100.0,
              backgroundColor: Colors.grey[200],
              color: Colors.blue,
            ),
          Expanded(
            child: activeCode.isEmpty
                ? const Center(child: Text('يرجى تسجيل كود للبدء'))
                : WebViewWidget(controller: _webViewController),
          ),
        ],
      ),
    );
  }
}
