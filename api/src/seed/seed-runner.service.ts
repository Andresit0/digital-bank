import { Injectable, Logger, OnModuleInit } from '@nestjs/common';
import {
  AccountSeedService,
  ExperienceSeedService,
  MovementSeedService,
  UserSeedService,
} from './seed_service';

@Injectable()
export class SeedRunnerService implements OnModuleInit {
  private readonly logger = new Logger(SeedRunnerService.name);

  constructor(
    private readonly userSeedService: UserSeedService,
    private readonly accountSeedService: AccountSeedService,
    private readonly movementSeedService: MovementSeedService,
    private readonly experienceSeedService: ExperienceSeedService,
  ) {}

  async onModuleInit(): Promise<void> {
    if (!this.isAutoSeedEnabled()) {
      this.logger.log('Seed skipped (disabled or production stage)');
      return;
    }
    try {
      await this.run();
    } catch (error) {
      this.logger.error(
        'Seed execution failed',
        error instanceof Error ? error.stack : undefined,
      );
    }
  }

  isDevStage(): boolean {
    return (process.env.STAGE ?? 'dev') !== 'production';
  }

  isAutoSeedEnabled(): boolean {
    return this.isDevStage() && process.env.SEED_ON_START !== 'false';
  }

  async run(): Promise<void> {
    const user = await this.userSeedService.createUser();
    await this.accountSeedService.createAccounts(user.code);
    await this.movementSeedService.createMovements();
    await this.experienceSeedService.createExperiences();
    this.logger.log('Seed of examples executed');
  }
}
