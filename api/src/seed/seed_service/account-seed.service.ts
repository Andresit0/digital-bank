import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Account } from '../../accounts/entities/account.entity';
import { initialData } from '../data/seed-data';

@Injectable()
export class AccountSeedService {
  constructor(
    @InjectRepository(Account)
    private readonly accountRepository: Repository<Account>,
  ) {}

  async createAccounts(userCode: number): Promise<Account[]> {
    await this.accountRepository
      .createQueryBuilder()
      .delete()
      .from(Account)
      .execute();

    const accounts = initialData.accounts.map((account) =>
      this.accountRepository.create({ ...account, userCode }),
    );
    return this.accountRepository.save(accounts);
  }
}
