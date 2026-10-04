import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User } from '../../auth/entities/user.entity';
import { initialData } from '../data/seed-data';

@Injectable()
export class UserSeedService {
  constructor(
    @InjectRepository(User)
    private readonly userRepository: Repository<User>,
  ) {}

  async createUser(): Promise<User> {
    await this.userRepository
      .createQueryBuilder()
      .delete()
      .from(User)
      .execute();
    await this.userRepository.query(
      `SELECT setval((SELECT pg_get_serial_sequence('user', 'code')), 1, false);`,
    );

    const user = this.userRepository.create(initialData.user);
    return this.userRepository.save(user);
  }
}
