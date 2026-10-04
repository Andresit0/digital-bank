import { Body, Controller, Get, Put } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { Auth } from '../auth/decorators';
import { ValidRoles } from '../auth/interfaces';
import { SwaggerDefaultResponses } from '../common/decorators/swagger.decorator';
import { UpdateExperienceDto } from './dto/update-experience.dto';
import { ExperienceService } from './experience.service';

@ApiTags('Experience')
@Controller('experience')
export class ExperienceController {
  constructor(private readonly experienceService: ExperienceService) {}

  @Get('home')
  @ApiBearerAuth()
  @Auth(ValidRoles.user)
  @SwaggerDefaultResponses()
  home() {
    return this.experienceService.getHome();
  }

  @Put('home')
  @ApiBearerAuth()
  @Auth(ValidRoles.user)
  @SwaggerDefaultResponses()
  updateHome(@Body() dto: UpdateExperienceDto) {
    return this.experienceService.updateHome(dto);
  }
}
