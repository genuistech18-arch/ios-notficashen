import { Notification } from '../notification.entity';

export class NotificationResponseDto {
  id: string;
  message: string;
  isRead: boolean;
  sentAt: Date;
  readAt: Date | null;
  deliveryStatus: string;

  static fromEntity(notification: Notification): NotificationResponseDto {
    return {
      id: notification.id,
      message: notification.message,
      isRead: notification.isRead,
      sentAt: notification.sentAt,
      readAt: notification.readAt,
      deliveryStatus: notification.deliveryStatus,
    };
  }
}
