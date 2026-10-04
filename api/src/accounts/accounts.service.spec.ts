import { Test } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';
import { AccountsService } from './accounts.service';
import { Account } from './entities/account.entity';

describe('AccountsService (unit)', () => {
  let service: AccountsService;
  let accountRepository: { find: jest.Mock };

  beforeEach(async () => {
    accountRepository = { find: jest.fn() };

    const moduleRef = await Test.createTestingModule({
      providers: [
        AccountsService,
        { provide: getRepositoryToken(Account), useValue: accountRepository },
      ],
    }).compile();

    service = moduleRef.get(AccountsService);
  });

  it('returns the repository accounts ordered by id', async () => {
    const accounts = [{ id: 'acc-1' }, { id: 'acc-2' }] as Account[];
    accountRepository.find.mockResolvedValue(accounts);

    await expect(service.findAll()).resolves.toBe(accounts);
    expect(accountRepository.find).toHaveBeenCalledWith({
      order: { id: 'ASC' },
    });
  });
});
