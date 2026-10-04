import { NotFoundException } from '@nestjs/common';
import { Test } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';
import { Account } from '../accounts/entities/account.entity';
import { Movement } from './entities/movement.entity';
import { MovementsService } from './movements.service';

describe('MovementsService (unit)', () => {
  let service: MovementsService;
  let movementRepository: { find: jest.Mock };
  let accountRepository: { findOne: jest.Mock };

  beforeEach(async () => {
    movementRepository = { find: jest.fn() };
    accountRepository = { findOne: jest.fn() };

    const moduleRef = await Test.createTestingModule({
      providers: [
        MovementsService,
        { provide: getRepositoryToken(Movement), useValue: movementRepository },
        { provide: getRepositoryToken(Account), useValue: accountRepository },
      ],
    }).compile();

    service = moduleRef.get(MovementsService);
  });

  it('returns movements ordered by occurredAt for an existing account', async () => {
    accountRepository.findOne.mockResolvedValue({ id: 'acc-1' } as Account);
    const movements = [{ id: 'mov-1' }] as Movement[];
    movementRepository.find.mockResolvedValue(movements);

    await expect(service.findByAccount('acc-1')).resolves.toBe(movements);
    expect(movementRepository.find).toHaveBeenCalledWith({
      where: { accountId: 'acc-1' },
      order: { occurredAt: 'DESC' },
    });
  });

  it('throws NotFoundException when the account does not exist', async () => {
    accountRepository.findOne.mockResolvedValue(null);

    await expect(service.findByAccount('unknown')).rejects.toBeInstanceOf(
      NotFoundException,
    );
    expect(movementRepository.find).not.toHaveBeenCalled();
  });
});
