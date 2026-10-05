import { Test } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';
import { User } from '../auth/entities/user.entity';
import {
  NotificationDelivery,
  NotificationSender,
} from './domain/notification-sender.interface';
import { NOTIFICATION_SENDER } from './domain/notification-sender.token';
import { DeviceInstallation } from './entities/device-installation.entity';
import { NotificationsService } from './notifications.service';

class FakeNotificationSender implements NotificationSender {
  sent: NotificationDelivery[] = [];

  async send(delivery: NotificationDelivery): Promise<string> {
    this.sent.push(delivery);
    return 'projects/demo/messages/fake-message-id';
  }
}

describe('NotificationsService (unit)', () => {
  let service: NotificationsService;
  let sender: FakeNotificationSender;
  let installationRepository: {
    findOne: jest.Mock;
    find: jest.Mock;
    create: jest.Mock;
    save: jest.Mock;
  };

  const user = { code: 1 } as User;

  beforeEach(async () => {
    sender = new FakeNotificationSender();
    installationRepository = {
      findOne: jest.fn(),
      find: jest.fn(),
      create: jest.fn((value) => value),
      save: jest.fn((value) => Promise.resolve(value)),
    };

    const moduleRef = await Test.createTestingModule({
      providers: [
        NotificationsService,
        { provide: NOTIFICATION_SENDER, useValue: sender },
        {
          provide: getRepositoryToken(DeviceInstallation),
          useValue: installationRepository,
        },
      ],
    }).compile();

    service = moduleRef.get(NotificationsService);
  });

  it('API-NTF-002 registers a new installation for the user', async () => {
    installationRepository.findOne.mockResolvedValue(null);

    const result = await service.register(user, {
      token: 'token-a',
      platform: 'android',
    });

    expect(installationRepository.create).toHaveBeenCalledWith({
      userCode: 1,
      token: 'token-a',
      platform: 'android',
    });
    expect(result.token).toBe('token-a');
  });

  it('API-NTF-005 is idempotent for the same user and token', async () => {
    installationRepository.findOne.mockResolvedValue({
      id: 'inst-1',
      userCode: 1,
      token: 'token-a',
      platform: 'android',
    });

    await service.register(user, { token: 'token-a', platform: 'android' });

    expect(installationRepository.create).not.toHaveBeenCalled();
    expect(installationRepository.save).toHaveBeenCalled();
  });

  it('API-NTF-008 sends type and movementId to the sender', async () => {
    installationRepository.find.mockResolvedValue([
      { id: 'inst-1', userCode: 1, token: 'token-a' },
    ]);

    const result = await service.send({
      userId: '1',
      type: 'movement',
      movementId: 'mov-1',
    });

    expect(sender.sent).toEqual([
      { token: 'token-a', type: 'movement', movementId: 'mov-1' },
    ]);
    expect(result.messageId).toBe('projects/demo/messages/fake-message-id');
  });

  it('fails when the user has no registered device', async () => {
    installationRepository.find.mockResolvedValue([]);

    await expect(
      service.send({ userId: '1', type: 'movement', movementId: 'mov-1' }),
    ).rejects.toThrow();
  });
});
