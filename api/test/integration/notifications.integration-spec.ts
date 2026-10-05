import { INestApplication } from '@nestjs/common';
import { getRepositoryToken } from '@nestjs/typeorm';
import request from 'supertest';
import { Repository } from 'typeorm';
import { DeviceInstallation } from '../../src/notifications/entities/device-installation.entity';
import {
  bearer,
  createTestApp,
  loginAsCustomer,
} from '../support/create-test-app';

describe('Notifications integration (register -> PostgreSQL)', () => {
  let app: INestApplication;
  let token: string;

  beforeAll(async () => {
    app = await createTestApp();
    token = await loginAsCustomer(app);
  });

  afterAll(async () => {
    await app?.close();
  });

  it('API-NTF-002 persists the device installation for the user', async () => {
    const repository = app.get<Repository<DeviceInstallation>>(
      getRepositoryToken(DeviceInstallation),
    );

    await repository.delete({ token: 'token-integration' });

    const body = await request(app.getHttpServer())
      .post('/notifications/register')
      .set('Authorization', bearer(token))
      .send({ token: 'token-integration', platform: 'android' })
      .expect(200);

    const stored = await repository.findOne({
      where: { token: 'token-integration' },
    });

    expect(stored).not.toBeNull();
    expect(stored?.id).toBe(body.body.id);
    expect(stored?.platform).toBe('android');
  });
});
