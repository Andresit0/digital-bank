import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Movement } from '../../movements/entities/movement.entity';
import { initialData } from '../data/seed-data';

@Injectable()
export class MovementSeedService {
  constructor(
    @InjectRepository(Movement)
    private readonly movementRepository: Repository<Movement>,
  ) {}

  async createMovements(): Promise<Movement[]> {
    await this.movementRepository
      .createQueryBuilder()
      .delete()
      .from(Movement)
      .execute();

    const movements = initialData.movements.map((movement) =>
      this.movementRepository.create(movement),
    );
    return this.movementRepository.save(movements);
  }
}
