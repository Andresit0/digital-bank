import { Body, Controller, HttpCode, HttpStatus, Post } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { Auth, GetUser } from '../auth/decorators';
import { ValidRoles } from '../auth/interfaces';
import { User } from '../auth/entities/user.entity';
import { SwaggerDefaultResponses } from '../common/decorators/swagger.decorator';
import { RegisterDeviceDto } from './dto/register-device.dto';
import { SendNotificationDto } from './dto/send-notification.dto';
import { NotificationsService } from './notifications.service';

@ApiTags('Notifications')
@Controller('notifications')
export class NotificationsController {
  constructor(private readonly notificationsService: NotificationsService) {}

  @Post('register')
  @ApiBearerAuth()
  @Auth(ValidRoles.user)
  @HttpCode(HttpStatus.OK)
  @SwaggerDefaultResponses()
  register(@GetUser() user: User, @Body() dto: RegisterDeviceDto) {
    return this.notificationsService.register(user, dto);
  }

  @Post('send')
  @ApiBearerAuth()
  @Auth(ValidRoles.user)
  @HttpCode(HttpStatus.OK)
  @SwaggerDefaultResponses()
  send(@Body() dto: SendNotificationDto) {
    return this.notificationsService.send(dto);
  }
}
