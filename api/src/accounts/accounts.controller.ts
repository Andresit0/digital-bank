import { Controller, Get } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { Auth } from '../auth/decorators';
import { ValidRoles } from '../auth/interfaces';
import { SwaggerDefaultResponses } from '../common/decorators/swagger.decorator';
import { AccountsService } from './accounts.service';

@ApiTags('Accounts')
@Controller('accounts')
export class AccountsController {
  constructor(private readonly accountsService: AccountsService) {}

  @Get()
  @ApiBearerAuth()
  @Auth(ValidRoles.user)
  @SwaggerDefaultResponses()
  findAll() {
    return this.accountsService.findAll();
  }
}
