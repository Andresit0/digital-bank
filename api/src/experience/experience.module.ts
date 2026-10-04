import { Module } from '@nestjs/common';
import { PassportModule } from '@nestjs/passport';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Experience } from './entities/experience.entity';
import { ExperienceController } from './experience.controller';
import { ExperienceService } from './experience.service';

@Module({
  controllers: [ExperienceController],
  providers: [ExperienceService],
  imports: [
    TypeOrmModule.forFeature([Experience]),
    PassportModule.register({ defaultStrategy: 'jwt' }),
  ],
})
export class ExperienceModule {}
