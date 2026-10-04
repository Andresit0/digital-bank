import { Controller, Get, Param } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { Auth } from '../auth/decorators';
import { ValidRoles } from '../auth/interfaces';
import { SwaggerDefaultResponses } from '../common/decorators/swagger.decorator';
import { MovementsService } from './movements.service';

@ApiTags('Movements')
@Controller('accounts')
export class MovementsController {
  constructor(private readonly movementsService: MovementsService) {}

  @Get(':accountId/movements')
  @ApiBearerAuth()
  @Auth(ValidRoles.user)
  @SwaggerDefaultResponses()
  findByAccount(@Param('accountId') accountId: string) {
    return this.movementsService.findByAccount(accountId);
  }
}
