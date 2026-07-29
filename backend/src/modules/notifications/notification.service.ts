import { Injectable, NotFoundException } from '@nestjs/common';
import { randomUUID } from 'crypto';
import { ClientService } from '../clients/client.service';
import { FcmClient } from '../../integrations/fcm/fcm.client';
import { NotificationRepository } from './notification.repository';
import { DeliveryStatus } from './notification.entity';
import { NotificationResponseDto } from './dto/notification-response.dto';

export type SendResult = { status: 'sent' | 'failed' | 'no_token' | 'not_found' };

const NOTIFICATION_TITLE = 'متابعة الطالب';

@Injectable()
export class NotificationService {
  constructor(
    private readonly clientService: ClientService,
    private readonly notifications: NotificationRepository,
    private readonly fcmClient: FcmClient,
  ) {}

  async sendNotification(code: string, message: string): Promise<SendResult> {
    const client = await this.clientService.findByCode(code);

    // Code unknown entirely: nothing to attach a Notification row to
    // (user_id is a required FK), so we only report the outcome — no persistence.
    if (!client) {
      return { status: 'not_found' };
    }

    if (!client.fcmToken) {
      await this.notifications.save(
        this.notifications.create({
          id: randomUUID(),
          userId: client.id,
          message,
          isRead: false,
          readAt: null,
          deliveryStatus: DeliveryStatus.NO_TOKEN,
        }),
      );
      return { status: 'no_token' };
    }

    const notificationId = randomUUID();
    const result = await this.fcmClient.sendToToken(
      client.fcmToken,
      NOTIFICATION_TITLE,
      message,
      { notification_id: notificationId },
    );

    if (result.outcome === 'stale_token') {
      await this.clientService.invalidateToken(client);
    }

    const deliveryStatus =
      result.outcome === 'sent' ? DeliveryStatus.SENT : DeliveryStatus.FAILED;

    await this.notifications.save(
      this.notifications.create({
        id: notificationId,
        userId: client.id,
        message,
        isRead: false,
        readAt: null,
        deliveryStatus,
      }),
    );

    return { status: result.outcome === 'sent' ? 'sent' : 'failed' };
  }

  async getHistoryForCode(code: string): Promise<NotificationResponseDto[]> {
    const client = await this.clientService.findByCode(code);
    if (!client) {
      throw new NotFoundException('Code not found');
    }

    const list = await this.notifications.findByUserId(client.id);
    return list.map(NotificationResponseDto.fromEntity);
  }

  async markRead(id: string): Promise<NotificationResponseDto> {
    const notification = await this.notifications.findById(id);
    if (!notification) {
      throw new NotFoundException('Notification not found');
    }

    if (!notification.isRead) {
      notification.isRead = true;
      notification.readAt = new Date();
      await this.notifications.save(notification);
    }

    return NotificationResponseDto.fromEntity(notification);
  }
}
