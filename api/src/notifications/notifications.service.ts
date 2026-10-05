import { Inject, Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User } from '../auth/entities/user.entity';
import { NOTIFICATION_SENDER } from './domain/notification-sender.token';
import { NotificationSender } from './domain/notification-sender.interface';
import { RegisterDeviceDto } from './dto/register-device.dto';
import { SendNotificationDto } from './dto/send-notification.dto';
import { DeviceInstallation } from './entities/device-installation.entity';

@Injectable()
export class NotificationsService {
  constructor(
    @InjectRepository(DeviceInstallation)
    private readonly installationRepository: Repository<DeviceInstallation>,
    @Inject(NOTIFICATION_SENDER)
    private readonly sender: NotificationSender,
  ) {}

  async register(
    user: User,
    dto: RegisterDeviceDto,
  ): Promise<DeviceInstallation> {
    const existing = await this.installationRepository.findOne({
      where: { userCode: user.code, token: dto.token },
    });

    if (existing) {
      existing.platform = dto.platform;
      return this.installationRepository.save(existing);
    }

    const installation = this.installationRepository.create({
      userCode: user.code,
      token: dto.token,
      platform: dto.platform,
    });
    return this.installationRepository.save(installation);
  }

  async send(dto: SendNotificationDto): Promise<{ messageId: string }> {
    const userCode = Number(dto.userId);
    const installations = await this.installationRepository.find({
      where: { userCode },
    });

    if (installations.length === 0) {
      throw new NotFoundException('No registered device for the user');
    }

    const messageId = await this.sender.send({
      token: installations[0].token,
      type: dto.type,
      movementId: dto.movementId,
    });

    return { messageId };
  }
}
