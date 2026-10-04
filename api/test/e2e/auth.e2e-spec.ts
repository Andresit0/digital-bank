import { INestApplication } from '@nestjs/common';
import request from 'supertest';
import { createTestApp } from '../support/create-test-app';

describe('Auth E2E (HTTP -> Auth -> Service -> PostgreSQL)', () => {
  let app: INestApplication;

  beforeAll(async () => {
    app = await createTestApp();
  });

  afterAll(async () => {
    await app?.close();
  });

  it('POST /auth/login rejects invalid credentials with 401', async () => {
    await request(app.getHttpServer())
      .post('/auth/login')
      .send({ email: 'customer@example.com', password: 'wrong' })
      .expect(401);
  });

  it('POST /auth/login rejects an invalid payload with 400', async () => {
    await request(app.getHttpServer())
      .post('/auth/login')
      .send({ email: 'not-an-email', password: '' })
      .expect(400);
  });

  it('GET /auth/me rejects a request without a token with 401', async () => {
    await request(app.getHttpServer()).get('/auth/me').expect(401);
  });

  it('login -> JWT -> /auth/me returns the authenticated user', async () => {
    const login = await request(app.getHttpServer())
      .post('/auth/login')
      .send({ email: 'customer@example.com', password: 'secret' })
      .expect(200);

    expect(typeof login.body.accessToken).toBe('string');

    const me = await request(app.getHttpServer())
      .get('/auth/me')
      .set('Authorization', `Bearer ${login.body.accessToken}`)
      .expect(200);

    expect(me.body).toMatchObject({
      email: 'customer@example.com',
      fullname: 'Customer Test',
    });
    expect(me.body.password).toBeUndefined();
  });

  it('protected data endpoints require the access token', async () => {
    await request(app.getHttpServer()).get('/accounts').expect(401);

    const login = await request(app.getHttpServer())
      .post('/auth/login')
      .send({ email: 'customer@example.com', password: 'secret' })
      .expect(200);

    const accounts = await request(app.getHttpServer())
      .get('/accounts')
      .set('Authorization', `Bearer ${login.body.accessToken}`)
      .expect(200);
    expect(Array.isArray(accounts.body)).toBe(true);
  });
});
