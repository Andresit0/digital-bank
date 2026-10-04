import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Account } from '../accounts/entities/account.entity';
import { User } from '../auth/entities/user.entity';
import { Experience } from '../experience/entities/experience.entity';
import { Movement } from '../movements/entities/movement.entity';
import { SeedController } from './seed.controller';
import { SeedRunnerService } from './seed-runner.service';
import {
  AccountSeedService,
  ExperienceSeedService,
  MovementSeedService,
  UserSeedService,
} from './seed_service';

@Module({
  controllers: [SeedController],
  providers: [
    SeedRunnerService,
    UserSeedService,
    AccountSeedService,
    MovementSeedService,
    ExperienceSeedService,
  ],
  imports: [TypeOrmModule.forFeature([User, Account, Movement, Experience])],
})
export class SeedModule {}
