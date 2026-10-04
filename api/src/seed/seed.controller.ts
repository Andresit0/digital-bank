import { Controller, Get, NotFoundException } from '@nestjs/common';
import { ApiResponse, ApiTags } from '@nestjs/swagger';
import { SeedRunnerService } from './seed-runner.service';

@ApiTags('Seed')
@Controller('seed')
export class SeedController {
  constructor(private readonly seedRunnerService: SeedRunnerService) {}

  @Get('createExamples')
  @ApiResponse({
    status: 200,
    description: 'Seed of examples has been executed',
  })
  @ApiResponse({
    status: 404,
    description: 'Not available outside development',
  })
  async createExamples() {
    if (!this.seedRunnerService.isDevStage()) {
      throw new NotFoundException();
    }
    await this.seedRunnerService.run();
    return { message: 'Seed of examples has been executed' };
  }
}
