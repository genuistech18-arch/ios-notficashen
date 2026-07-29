import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication, ValidationPipe } from '@nestjs/common';
import { getRepositoryToken } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import request from 'supertest';
import { App } from 'supertest/types';
import { AppModule } from '../src/app.module';
import { Client } from '../src/modules/clients/client.entity';
import { Notification } from '../src/modules/notifications/notification.entity';
import { FcmClient } from '../src/integrations/fcm/fcm.client';

const API_KEY = 'test-only-api-key';

describe('Notifications (e2e)', () => {
  let app: INestApplication<App>;
  let clientRepo: Repository<Client>;
  let notificationRepo: Repository<Notification>;
  let fcmClient: { sendToToken: jest.Mock };

  const codeWithToken = '3001-e2e';
  const codeWithoutToken = '3002-e2e';

  beforeAll(async () => {
    fcmClient = { sendToToken: jest.fn() };

    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    })
      .overrideProvider(FcmClient)
      .useValue(fcmClient)
      .compile();

    app = moduleFixture.createNestApplication();
    app.useGlobalPipes(new ValidationPipe({ whitelist: true, transform: true }));
    await app.init();

    clientRepo = moduleFixture.get(getRepositoryToken(Client));
    notificationRepo = moduleFixture.get(getRepositoryToken(Notification));
  });

  beforeEach(async () => {
    fcmClient.sendToToken.mockReset();
    await clientRepo.delete({ code: codeWithToken });
    await clientRepo.delete({ code: codeWithoutToken });
    await clientRepo.save(
      clientRepo.create({ code: codeWithToken, fcmToken: 'a-real-looking-token' }),
    );
    await clientRepo.save(
      clientRepo.create({ code: codeWithoutToken, fcmToken: null }),
    );
  });

  afterAll(async () => {
    await clientRepo.delete({ code: codeWithToken });
    await clientRepo.delete({ code: codeWithoutToken });
    await app.close();
  });

  describe('POST /api/v1/notifications/send', () => {
    it('rejects requests without an API key', () => {
      return request(app.getHttpServer())
        .post('/api/v1/notifications/send')
        .send({ code: codeWithToken, message: 'hi' })
        .expect(401);
    });

    it('reports not_found for an unknown code without throwing', () => {
      return request(app.getHttpServer())
        .post('/api/v1/notifications/send')
        .set('x-api-key', API_KEY)
        .send({ code: 'no-such-code', message: 'hi' })
        .expect(201)
        .expect({ status: 'not_found' });
    });

    it('reports no_token and persists a record when the client has no token', async () => {
      await request(app.getHttpServer())
        .post('/api/v1/notifications/send')
        .set('x-api-key', API_KEY)
        .send({ code: codeWithoutToken, message: 'hi' })
        .expect(201)
        .expect({ status: 'no_token' });

      const client = await clientRepo.findOneBy({ code: codeWithoutToken });
      const notifications = await notificationRepo.findBy({ userId: client!.id });
      expect(notifications).toHaveLength(1);
      expect(notifications[0].deliveryStatus).toBe('no_token');
    });

    it('sends via FCM and persists a sent record on success', async () => {
      fcmClient.sendToToken.mockResolvedValueOnce({ outcome: 'sent' });

      await request(app.getHttpServer())
        .post('/api/v1/notifications/send')
        .set('x-api-key', API_KEY)
        .send({ code: codeWithToken, message: 'Your order is ready' })
        .expect(201)
        .expect({ status: 'sent' });

      const client = await clientRepo.findOneBy({ code: codeWithToken });
      const notifications = await notificationRepo.findBy({ userId: client!.id });
      expect(notifications).toHaveLength(1);
      expect(notifications[0].deliveryStatus).toBe('sent');
    });

    it('persists a failed record and does not throw when FCM send fails', async () => {
      fcmClient.sendToToken.mockResolvedValueOnce({ outcome: 'error' });

      await request(app.getHttpServer())
        .post('/api/v1/notifications/send')
        .set('x-api-key', API_KEY)
        .send({ code: codeWithToken, message: 'will fail' })
        .expect(201)
        .expect({ status: 'failed' });
    });
  });

  describe('GET /api/v1/clients/:code/notifications + PATCH mark-read', () => {
    it('lists history newest-first and mark-read is idempotent', async () => {
      fcmClient.sendToToken.mockResolvedValue({ outcome: 'sent' });

      await request(app.getHttpServer())
        .post('/api/v1/notifications/send')
        .set('x-api-key', API_KEY)
        .send({ code: codeWithToken, message: 'first' })
        .expect(201);
      await request(app.getHttpServer())
        .post('/api/v1/notifications/send')
        .set('x-api-key', API_KEY)
        .send({ code: codeWithToken, message: 'second' })
        .expect(201);

      const historyRes = await request(app.getHttpServer())
        .get(`/api/v1/clients/${codeWithToken}/notifications`)
        .expect(200);

      expect(historyRes.body).toHaveLength(2);
      expect(historyRes.body[0].message).toBe('second');
      expect(historyRes.body[1].message).toBe('first');

      const id = historyRes.body[0].id;
      const firstRead = await request(app.getHttpServer())
        .patch(`/api/v1/notifications/${id}/read`)
        .expect(200);
      expect(firstRead.body.isRead).toBe(true);
      const readAt = firstRead.body.readAt;

      const secondRead = await request(app.getHttpServer())
        .patch(`/api/v1/notifications/${id}/read`)
        .expect(200);
      expect(secondRead.body.readAt).toBe(readAt);
    });
  });
});
