import { INestApplication } from '@nestjs/common';
import request from 'supertest';
import { createTestApp, loginAsCustomer } from '../support/create-test-app';

describe('Accounts (integration: HTTP -> Controller -> Service -> PostgreSQL)', () => {
  let app: INestApplication;
  let token: string;

  beforeAll(async () => {
    app = await createTestApp();
    token = await loginAsCustomer(app);
  });

  afterAll(async () => {
    await app?.close();
  });

  it('GET /accounts without a token returns 401', async () => {
    await request(app.getHttpServer()).get('/accounts').expect(401);
  });

  it('GET /accounts returns the seeded accounts with numeric balances', async () => {
    const res = await request(app.getHttpServer())
      .get('/accounts')
      .set('Authorization', `Bearer ${token}`)
      .expect(200);

    expect(Array.isArray(res.body)).toBe(true);

    const account = res.body.find((item: any) => item.id === 'acc-1');
    expect(account).toMatchObject({
      id: 'acc-1',
      type: 'savings',
      displayName: 'Savings Account',
      maskedNumber: '****1234',
    });
    expect(typeof account.availableBalance).toBe('number');
    expect(account.availableBalance).toBeCloseTo(1500.5);
  });

  it('GET /accounts returns an empty array shape that the client can consume', async () => {
    const res = await request(app.getHttpServer())
      .get('/accounts')
      .set('Authorization', `Bearer ${token}`)
      .expect(200);
    expect(Array.isArray(res.body)).toBe(true);
  });
});
