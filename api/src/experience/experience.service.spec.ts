import { BadRequestException } from '@nestjs/common';
import { Test } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';
import { Experience } from './entities/experience.entity';
import { ExperienceService } from './experience.service';

describe('ExperienceService (unit)', () => {
  let service: ExperienceService;
  let experienceRepository: {
    findOne: jest.Mock;
    create: jest.Mock;
    save: jest.Mock;
  };

  beforeEach(async () => {
    experienceRepository = {
      findOne: jest.fn(),
      create: jest.fn((value) => value),
      save: jest.fn((value) => Promise.resolve(value)),
    };

    const moduleRef = await Test.createTestingModule({
      providers: [
        ExperienceService,
        {
          provide: getRepositoryToken(Experience),
          useValue: experienceRepository,
        },
      ],
    }).compile();

    service = moduleRef.get(ExperienceService);
  });

  it('returns an empty definition when none is stored', async () => {
    experienceRepository.findOne.mockResolvedValue(null);

    await expect(service.getHome()).resolves.toEqual({
      experience: 'account_home',
      version: 0,
      sections: [],
    });
  });

  it('updates and validates a supported section', async () => {
    experienceRepository.findOne.mockResolvedValue(null);

    const result = await service.updateHome({
      version: 2,
      sections: [
        { type: 'promotion', title: 'A brand new offer', description: 'Live' },
      ],
    });

    expect(result).toEqual({
      experience: 'account_home',
      version: 2,
      sections: [
        { type: 'promotion', title: 'A brand new offer', description: 'Live' },
      ],
    });
  });

  it('rejects an unsupported section type', async () => {
    await expect(
      service.updateHome({ version: 2, sections: [{ type: 'unknown' }] }),
    ).rejects.toBeInstanceOf(BadRequestException);
  });

  it('rejects a quick_action with an unsupported action', async () => {
    await expect(
      service.updateHome({
        version: 2,
        sections: [{ type: 'quick_action', label: 'Go', action: 'nope' }],
      }),
    ).rejects.toBeInstanceOf(BadRequestException);
  });
});
