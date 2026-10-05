import { Module } from '@nestjs/common';
import { PassportModule } from '@nestjs/passport';
import { TypeOrmModule } from '@nestjs/typeorm';
import { User } from '../auth/entities/user.entity';
import { NOTIFICATION_SENDER } from './domain/notification-sender.token';
import { DeviceInstallation } from './entities/device-installation.entity';
import { FirebaseNotificationSender } from './infrastructure/firebase-notification.sender';
import { NotificationsController } from './notifications.controller';
import { NotificationsService } from './notifications.service';

@Module({
  controllers: [NotificationsController],
  providers: [
    NotificationsService,
    { provide: NOTIFICATION_SENDER, useClass: FirebaseNotificationSender },
  ],
  imports: [
    TypeOrmModule.forFeature([DeviceInstallation, User]),
    PassportModule.register({ defaultStrategy: 'jwt' }),
  ],
})
export class NotificationsModule {}
