import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/notification_model.dart';

class NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const NotificationTile({
    super.key,
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final formattedTime =
        DateFormat.yMMMd().add_jm().format(notification.sentAt.toLocal());

    return ListTile(
      onTap: onTap,
      leading: notification.isRead
          ? const SizedBox(width: 12)
          : Icon(Icons.circle, size: 12, color: Theme.of(context).colorScheme.primary),
      title: Text(
        notification.message,
        style: TextStyle(
          fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
        ),
      ),
      subtitle: Text(formattedTime),
    );
  }
}
