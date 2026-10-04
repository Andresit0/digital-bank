import { INestApplication } from '@nestjs/common';
import request from 'supertest';
import { createTestApp, loginAsCustomer } from '../support/create-test-app';

describe('Experience (integration: HTTP -> Controller -> Service -> PostgreSQL)', () => {
  let app: INestApplication;
  let accessToken: string;

  beforeAll(async () => {
    app = await createTestApp();
    accessToken = await loginAsCustomer(app);
  });

  afterAll(async () => {
    await app?.close();
  });

  it('GET /experience/home without a token returns 401', async () => {
    await request(app.getHttpServer()).get('/experience/home').expect(401);
  });

  it('GET /experience/home returns the account_home definition with sections', async () => {
    const res = await request(app.getHttpServer())
      .get('/experience/home')
      .set('Authorization', `Bearer ${accessToken}`)
      .expect(200);

    expect(res.body.experience).toBe('account_home');
    expect(typeof res.body.version).toBe('number');
    expect(Array.isArray(res.body.sections)).toBe(true);
    expect(res.body.sections.length).toBeGreaterThanOrEqual(1);
  });

  it('PUT /experience/home is protected', async () => {
    await request(app.getHttpServer())
      .put('/experience/home')
      .send({ version: 2, sections: [] })
      .expect(401);
  });

  it('PUT /experience/home updates the dynamic definition with a valid token', async () => {
    const update = await request(app.getHttpServer())
      .put('/experience/home')
      .set('Authorization', `Bearer ${accessToken}`)
      .send({
        version: 9,
        sections: [
          {
            type: 'promotion',
            title: 'A brand new offer',
            description: 'Composed dynamically',
          },
        ],
      })
      .expect(200);

    expect(update.body).toEqual({
      experience: 'account_home',
      version: 9,
      sections: [
        {
          type: 'promotion',
          title: 'A brand new offer',
          description: 'Composed dynamically',
        },
      ],
    });

    const res = await request(app.getHttpServer())
      .get('/experience/home')
      .set('Authorization', `Bearer ${accessToken}`)
      .expect(200);
    expect(res.body.version).toBe(9);
  });
});
