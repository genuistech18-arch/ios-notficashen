import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication, ValidationPipe } from '@nestjs/common';
import { getRepositoryToken } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import request from 'supertest';
import { App } from 'supertest/types';
import { AppModule } from '../src/app.module';
import { Client } from '../src/modules/clients/client.entity';

describe('Clients (e2e)', () => {
  let app: INestApplication<App>;
  let clientRepo: Repository<Client>;

  const seededCode = '2001-e2e';

  beforeAll(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleFixture.createNestApplication();
    app.useGlobalPipes(new ValidationPipe({ whitelist: true, transform: true }));
    await app.init();

    clientRepo = moduleFixture.get(getRepositoryToken(Client));
  });

  beforeEach(async () => {
    await clientRepo.delete({ code: seededCode });
    await clientRepo.save(clientRepo.create({ code: seededCode, fcmToken: null }));
  });

  afterAll(async () => {
    await clientRepo.delete({ code: seededCode });
    await app.close();
  });

  it('rejects registration for a code that does not exist', () => {
    return request(app.getHttpServer())
      .post('/api/v1/clients/register')
      .send({ code: 'does-not-exist', fcm_token: 'tok' })
      .expect(404);
  });

  it('registers an existing code and persists the fcm token', async () => {
    await request(app.getHttpServer())
      .post('/api/v1/clients/register')
      .send({ code: seededCode, fcm_token: 'token-a' })
      .expect(201);

    const stored = await clientRepo.findOneBy({ code: seededCode });
    expect(stored?.fcmToken).toBe('token-a');
  });

  it('overwrites the token on re-registration instead of duplicating the row', async () => {
    await request(app.getHttpServer())
      .post('/api/v1/clients/register')
      .send({ code: seededCode, fcm_token: 'token-a' })
      .expect(201);

    await request(app.getHttpServer())
      .post('/api/v1/clients/register')
      .send({ code: seededCode, fcm_token: 'token-b' })
      .expect(201);

    const matches = await clientRepo.findBy({ code: seededCode });
    expect(matches).toHaveLength(1);
    expect(matches[0].fcmToken).toBe('token-b');
  });
});
