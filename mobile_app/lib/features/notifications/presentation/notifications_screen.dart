import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../registration/controller/account_controller.dart';
import '../controller/notifications_controller.dart';
import 'widgets/notification_tile.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notificationsControllerProvider);
    final controller = ref.read(notificationsControllerProvider.notifier);
    final accountState = ref.watch(accountControllerProvider);
    final activeCode = accountState.activeCode ?? 'N/A';

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('سجل الإشعارات', style: TextStyle(fontSize: 18)),
            Text(
              'الكود: $activeCode',
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: controller.refresh,
        child: state.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => ListView(
            children: const [
              SizedBox(height: 80),
              Center(child: Text('لم نتمكن من تحميل الإشعارات')),
            ],
          ),
          data: (notifications) {
            if (notifications.isEmpty) {
              return ListView(
                children: const [
                  SizedBox(height: 80),
                  Center(child: Text('لا توجد إشعارات حالياً لهذا الكود')),
                ],
              );
            }
            return ListView.separated(
              itemCount: notifications.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return NotificationTile(
                  notification: notification,
                  onTap: () => controller.markAsRead(notification.id),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
