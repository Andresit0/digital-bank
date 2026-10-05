import { INestApplication } from '@nestjs/common';
import request from 'supertest';
import {
  bearer,
  createTestApp,
  loginAsCustomer,
} from '../support/create-test-app';

describe('Notifications E2E (HTTP -> Notifications -> PostgreSQL)', () => {
  let app: INestApplication;
  let token: string;

  beforeAll(async () => {
    app = await createTestApp();
    token = await loginAsCustomer(app);
  });

  afterAll(async () => {
    await app?.close();
  });

  it('API-NTF-003 POST /notifications/register requires a token', async () => {
    await request(app.getHttpServer())
      .post('/notifications/register')
      .send({ token: 'token-a', platform: 'android' })
      .expect(401);
  });

  it('API-NTF-006 POST /notifications/send requires a token', async () => {
    await request(app.getHttpServer())
      .post('/notifications/send')
      .send({ userId: '1', type: 'movement', movementId: 'mov-1' })
      .expect(401);
  });

  it('API-NTF-004 registers the device for the authenticated user', async () => {
    const response = await request(app.getHttpServer())
      .post('/notifications/register')
      .set('Authorization', bearer(token))
      .send({ token: 'token-e2e', platform: 'android' })
      .expect(200);

    expect(response.body).toMatchObject({
      token: 'token-e2e',
      platform: 'android',
    });
    expect(response.body.userCode).toBeDefined();
  });

  it('API-NTF-005 registration is idempotent for the same user and token', async () => {
    const first = await request(app.getHttpServer())
      .post('/notifications/register')
      .set('Authorization', bearer(token))
      .send({ token: 'token-e2e', platform: 'android' })
      .expect(200);

    const second = await request(app.getHttpServer())
      .post('/notifications/register')
      .set('Authorization', bearer(token))
      .send({ token: 'token-e2e', platform: 'android' })
      .expect(200);

    expect(second.body.id).toBe(first.body.id);
  });

  it('API-NTF-006 send with a token but no registered device returns 404', async () => {
    await request(app.getHttpServer())
      .post('/notifications/send')
      .set('Authorization', bearer(token))
      .send({
        userId: '999999',
        type: 'movement',
        movementId: 'mov-1',
        title: 'Salary received',
        body: '+$500.00 in Savings',
      })
      .expect(404);
  });
});
