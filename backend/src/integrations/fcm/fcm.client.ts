import { Inject, Injectable, Logger } from '@nestjs/common';
import { type App } from 'firebase-admin/app';
import { getMessaging } from 'firebase-admin/messaging';
import { FIREBASE_ADMIN } from '../../config/firebase.module';

export type FcmSendResult =
  | { outcome: 'sent' }
  | { outcome: 'stale_token' }
  | { outcome: 'error' };

const STALE_TOKEN_ERROR_CODES = new Set([
  'messaging/registration-token-not-registered',
  'messaging/invalid-registration-token',
  'messaging/invalid-argument',
]);

@Injectable()
export class FcmClient {
  private readonly logger = new Logger(FcmClient.name);

  constructor(@Inject(FIREBASE_ADMIN) private readonly firebaseApp: App | null) {}

  async sendToToken(
    token: string,
    title: string,
    body: string,
    data: Record<string, string>,
  ): Promise<FcmSendResult> {
    if (!this.firebaseApp) {
      this.logger.warn(
        'Firebase Admin is not initialized (missing service account) — skipping FCM send',
      );
      return { outcome: 'error' };
    }

    try {
      await getMessaging(this.firebaseApp).send({
        token,
        notification: { title, body },
        android: {
          priority: 'high',
          notification: {
            sound: 'default',
            channelId: 'high_importance_channel',
            priority: 'high',
          },
        },
        data,
      });
      return { outcome: 'sent' };
    } catch (error) {
      const code = (error as { code?: string }).code;
      if (code && STALE_TOKEN_ERROR_CODES.has(code)) {
        this.logger.warn(`Stale FCM token detected (${code})`);
        return { outcome: 'stale_token' };
      }

      this.logger.error('FCM send failed', error as Error);
      return { outcome: 'error' };
    }
  }
}
