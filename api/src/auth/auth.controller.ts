import {
  Body,
  Controller,
  Get,
  HttpCode,
  HttpStatus,
  Post,
} from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { SwaggerDefaultResponses } from '../common/decorators/swagger.decorator';
import { AuthService } from './auth.service';
import { Auth, GetUser } from './decorators';
import { LoginDto } from './dto/login.dto';
import { User } from './entities/user.entity';
import { ValidRoles } from './interfaces';

@ApiTags('Auth')
@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post('login')
  @HttpCode(HttpStatus.OK)
  @SwaggerDefaultResponses()
  login(@Body() loginDto: LoginDto) {
    return this.authService.login(loginDto);
  }

  @Get('me')
  @ApiBearerAuth()
  @Auth(ValidRoles.user)
  @SwaggerDefaultResponses()
  me(@GetUser() user: User) {
    delete user.password;
    return user;
  }
}
