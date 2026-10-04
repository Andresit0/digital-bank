import { INestApplication } from '@nestjs/common';
import request from 'supertest';
import { createTestApp, loginAsCustomer } from '../support/create-test-app';

describe('Seed (integration: HTTP -> Controller -> Seed services -> PostgreSQL)', () => {
  let app: INestApplication;
  let token: string;

  beforeAll(async () => {
    app = await createTestApp();
    token = await loginAsCustomer(app);
  });

  afterAll(async () => {
    await app?.close();
  });

  it('GET /seed/createExamples resets and reloads the example dataset', async () => {
    const seedResponse = await request(app.getHttpServer())
      .get('/seed/createExamples')
      .expect(200);
    expect(seedResponse.body.message).toMatch(/executed/i);

    const accounts = await request(app.getHttpServer())
      .get('/accounts')
      .set('Authorization', `Bearer ${token}`)
      .expect(200);
    expect(accounts.body).toHaveLength(3);

    const acc1Movements = await request(app.getHttpServer())
      .get('/accounts/acc-1/movements')
      .set('Authorization', `Bearer ${token}`)
      .expect(200);
    expect(acc1Movements.body).toHaveLength(5);

    const acc3Movements = await request(app.getHttpServer())
      .get('/accounts/acc-3/movements')
      .set('Authorization', `Bearer ${token}`)
      .expect(200);
    expect(acc3Movements.body).toEqual([]);

    const experience = await request(app.getHttpServer())
      .get('/experience/home')
      .set('Authorization', `Bearer ${token}`)
      .expect(200);
    expect(experience.body.version).toBe(1);
    expect(experience.body.sections).toHaveLength(3);
  });

  it('reloads the dataset to a known state after mutation', async () => {
    await request(app.getHttpServer())
      .put('/experience/home')
      .set('Authorization', `Bearer ${token}`)
      .send({ version: 42, sections: [] })
      .expect(200);

    const mutated = await request(app.getHttpServer())
      .get('/experience/home')
      .set('Authorization', `Bearer ${token}`)
      .expect(200);
    expect(mutated.body.version).toBe(42);

    await request(app.getHttpServer()).get('/seed/createExamples').expect(200);

    const reset = await request(app.getHttpServer())
      .get('/experience/home')
      .set('Authorization', `Bearer ${token}`)
      .expect(200);
    expect(reset.body.version).toBe(1);
    expect(reset.body.sections).toHaveLength(3);
  });
});
