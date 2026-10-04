import { Test } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';
import { Account } from '../../accounts/entities/account.entity';
import { initialData } from '../data/seed-data';
import { AccountSeedService } from './account-seed.service';

describe('AccountSeedService (unit)', () => {
  let service: AccountSeedService;
  let accountRepository: {
    createQueryBuilder: jest.Mock;
    create: jest.Mock;
    save: jest.Mock;
  };
  let deleteChain: {
    delete: jest.Mock;
    from: jest.Mock;
    execute: jest.Mock;
  };

  beforeEach(async () => {
    deleteChain = {
      delete: jest.fn().mockReturnThis(),
      from: jest.fn().mockReturnThis(),
      execute: jest.fn().mockResolvedValue(undefined),
    };
    accountRepository = {
      createQueryBuilder: jest.fn(() => deleteChain),
      create: jest.fn((value) => value),
      save: jest.fn((value) => Promise.resolve(value)),
    };

    const moduleRef = await Test.createTestingModule({
      providers: [
        AccountSeedService,
        {
          provide: getRepositoryToken(Account),
          useValue: accountRepository,
        },
      ],
    }).compile();

    service = moduleRef.get(AccountSeedService);
  });

  it('resets the accounts table and inserts the initial dataset', async () => {
    const result = await service.createAccounts(7);

    expect(accountRepository.createQueryBuilder).toHaveBeenCalled();
    expect(deleteChain.execute).toHaveBeenCalled();
    expect(accountRepository.save).toHaveBeenCalled();
    expect(result).toHaveLength(initialData.accounts.length);
    result.forEach((account) => expect(account.userCode).toBe(7));
  });
});
