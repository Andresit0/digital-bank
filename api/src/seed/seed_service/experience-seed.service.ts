import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Experience } from '../../experience/entities/experience.entity';
import { initialData } from '../data/seed-data';

@Injectable()
export class ExperienceSeedService {
  constructor(
    @InjectRepository(Experience)
    private readonly experienceRepository: Repository<Experience>,
  ) {}

  async createExperiences(): Promise<Experience[]> {
    await this.experienceRepository
      .createQueryBuilder()
      .delete()
      .from(Experience)
      .execute();

    const experiences = initialData.experiences.map((experience) =>
      this.experienceRepository.create(experience),
    );
    return this.experienceRepository.save(experiences);
  }
}
