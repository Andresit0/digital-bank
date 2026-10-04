import { INestApplication, ValidationPipe } from '@nestjs/common';
import { Test } from '@nestjs/testing';
import request from 'supertest';
import { AppModule } from '../../src/app.module';

export async function createTestApp(): Promise<INestApplication> {
  process.env.STAGE = 'dev';
  process.env.DB_NAME = process.env.DB_NAME_TEST ?? 'digital_bank_test';
  process.env.SEED_ON_START = 'true';

  const moduleRef = await Test.createTestingModule({
    imports: [AppModule],
  }).compile();

  const app = moduleRef.createNestApplication();
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
      transformOptions: { enableImplicitConversion: true },
    }),
  );

  await app.init();
  return app;
}

export async function loginAsCustomer(app: INestApplication): Promise<string> {
  const response = await request(app.getHttpServer())
    .post('/auth/login')
    .send({ email: 'customer@example.com', password: 'secret' })
    .expect(200);
  return response.body.accessToken;
}

export function bearer(token: string): string {
  return `Bearer ${token}`;
}
