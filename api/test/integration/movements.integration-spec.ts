import { INestApplication } from '@nestjs/common';
import request from 'supertest';
import { createTestApp, loginAsCustomer } from '../support/create-test-app';

describe('Movements (integration: HTTP -> Controller -> Service -> PostgreSQL)', () => {
  let app: INestApplication;
  let token: string;

  beforeAll(async () => {
    app = await createTestApp();
    token = await loginAsCustomer(app);
  });

  afterAll(async () => {
    await app?.close();
  });

  it('GET /accounts/acc-1/movements without a token returns 401', async () => {
    await request(app.getHttpServer())
      .get('/accounts/acc-1/movements')
      .expect(401);
  });

  it('GET /accounts/acc-1/movements returns the seeded movements', async () => {
    const res = await request(app.getHttpServer())
      .get('/accounts/acc-1/movements')
      .set('Authorization', `Bearer ${token}`)
      .expect(200);

    expect(Array.isArray(res.body)).toBe(true);
    expect(res.body.length).toBeGreaterThanOrEqual(2);

    const movement = res.body.find((item: any) => item.id === 'mov-1');
    expect(movement).toMatchObject({
      accountId: 'acc-1',
      type: 'credit',
      currency: 'USD',
      description: 'Salary',
    });
    expect(typeof movement.amount).toBe('number');
    expect(typeof movement.occurredAt).toBe('string');
    expect(Number.isNaN(Date.parse(movement.occurredAt))).toBe(false);
  });

  it('GET /accounts/unknown/movements returns 404 for a non-existing account', async () => {
    await request(app.getHttpServer())
      .get('/accounts/unknown/movements')
      .set('Authorization', `Bearer ${token}`)
      .expect(404);
  });
});
