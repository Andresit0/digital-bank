import { UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { Test } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';
import * as bcrypt from 'bcryptjs';
import { AuthService } from './auth.service';
import { User } from './entities/user.entity';

describe('AuthService (unit)', () => {
  let service: AuthService;
  let userRepository: { findOne: jest.Mock };
  let jwtService: { sign: jest.Mock };

  const buildUser = (overrides: Partial<User> = {}): User =>
    ({
      code: 1,
      fullname: 'Customer Test',
      email: 'customer@example.com',
      password: bcrypt.hashSync('secret', 10),
      isActive: true,
      roles: ['user'],
      ...overrides,
    } as User);

  beforeEach(async () => {
    userRepository = { findOne: jest.fn() };
    jwtService = { sign: jest.fn().mockReturnValue('signed-token') };

    const moduleRef = await Test.createTestingModule({
      providers: [
        AuthService,
        { provide: getRepositoryToken(User), useValue: userRepository },
        { provide: JwtService, useValue: jwtService },
      ],
    }).compile();

    service = moduleRef.get(AuthService);
  });

  it('returns an access token for valid credentials', async () => {
    userRepository.findOne.mockResolvedValue(buildUser());

    const result = await service.login({
      email: 'Customer@Example.com',
      password: 'secret',
    });

    expect(result).toEqual({ accessToken: 'signed-token' });
    expect(userRepository.findOne).toHaveBeenCalledWith({
      where: { email: 'customer@example.com' },
    });
    expect(jwtService.sign).toHaveBeenCalledWith({ code: 1 });
  });

  it('throws UnauthorizedException when the user does not exist', async () => {
    userRepository.findOne.mockResolvedValue(null);

    await expect(
      service.login({ email: 'missing@example.com', password: 'secret' }),
    ).rejects.toBeInstanceOf(UnauthorizedException);
  });

  it('throws UnauthorizedException when the password does not match', async () => {
    userRepository.findOne.mockResolvedValue(buildUser());

    await expect(
      service.login({ email: 'customer@example.com', password: 'wrong' }),
    ).rejects.toBeInstanceOf(UnauthorizedException);
  });

  it('throws UnauthorizedException when the account is inactive', async () => {
    userRepository.findOne.mockResolvedValue(
      buildUser({ isActive: false, password: bcrypt.hashSync('secret', 10) }),
    );

    await expect(
      service.login({ email: 'customer@example.com', password: 'secret' }),
    ).rejects.toBeInstanceOf(UnauthorizedException);
  });
});
