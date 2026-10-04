import { BadRequestException, Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { HOME_EXPERIENCE_KEY } from './experience.constants';
import { UpdateExperienceDto } from './dto/update-experience.dto';
import { Experience } from './entities/experience.entity';

export interface ExperienceView {
  experience: string;
  version: number;
  sections: Record<string, unknown>[];
}

@Injectable()
export class ExperienceService {
  constructor(
    @InjectRepository(Experience)
    private readonly experienceRepository: Repository<Experience>,
  ) {}

  async getHome(): Promise<ExperienceView> {
    const found = await this.experienceRepository.findOne({
      where: { experience: HOME_EXPERIENCE_KEY },
    });

    if (!found) {
      return { experience: HOME_EXPERIENCE_KEY, version: 0, sections: [] };
    }

    return {
      experience: found.experience,
      version: found.version,
      sections: found.sections ?? [],
    };
  }

  async updateHome(dto: UpdateExperienceDto): Promise<ExperienceView> {
    const sections = (dto.sections ?? []).map((section) =>
      this.validateSection(section),
    );

    let found = await this.experienceRepository.findOne({
      where: { experience: HOME_EXPERIENCE_KEY },
    });

    if (!found) {
      found = this.experienceRepository.create({
        experience: HOME_EXPERIENCE_KEY,
        version: dto.version,
        sections,
      });
    } else {
      found.version = dto.version;
      found.sections = sections;
    }

    const saved = await this.experienceRepository.save(found);
    return {
      experience: saved.experience,
      version: saved.version,
      sections: saved.sections ?? [],
    };
  }

  private validateSection(
    section: Record<string, unknown>,
  ): Record<string, unknown> {
    const type = section?.type;

    if (type === 'promotion') {
      if (typeof section.title !== 'string') {
        throw new BadRequestException('promotion.title must be a string');
      }
      if (
        section.description !== undefined &&
        typeof section.description !== 'string'
      ) {
        throw new BadRequestException('promotion.description must be a string');
      }
      return {
        type,
        title: section.title,
        ...(section.description !== undefined
          ? { description: section.description }
          : {}),
      };
    }

    if (type === 'quick_action') {
      if (typeof section.label !== 'string') {
        throw new BadRequestException('quick_action.label must be a string');
      }
      if (
        section.action !== 'view_movements' &&
        section.action !== 'view_accounts'
      ) {
        throw new BadRequestException(
          'quick_action.action must be view_movements or view_accounts',
        );
      }
      return { type, label: section.label, action: section.action };
    }

    throw new BadRequestException(`unsupported section type: ${String(type)}`);
  }
}
