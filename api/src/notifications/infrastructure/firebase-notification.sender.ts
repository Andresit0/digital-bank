import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { App, cert, getApps, initializeApp } from 'firebase-admin/app';
import { getMessaging, Messaging } from 'firebase-admin/messaging';
import {
  NotificationDelivery,
  NotificationSender,
} from '../domain/notification-sender.interface';

@Injectable()
export class FirebaseNotificationSender implements NotificationSender {
  private readonly logger = new Logger(FirebaseNotificationSender.name);
  private messaging?: Messaging;

  constructor(private readonly config: ConfigService) {}

  async send(delivery: NotificationDelivery): Promise<string> {
    const messaging = this.resolveMessaging();
    return messaging.send({
      token: delivery.token,
      data: {
        type: delivery.type,
        movementId: delivery.movementId,
      },
    });
  }

  private resolveMessaging(): Messaging {
    if (this.messaging) {
      return this.messaging;
    }

    const app = this.resolveApp();
    this.messaging = getMessaging(app);
    return this.messaging;
  }

  private resolveApp(): App {
    const existing = getApps();
    if (existing.length > 0) {
      return existing[0];
    }

    const projectId = this.config.get<string>('FIREBASE_PROJECT_ID');
    const clientEmail = this.config.get<string>('FIREBASE_CLIENT_EMAIL');
    const privateKey = this.config
      .get<string>('FIREBASE_PRIVATE_KEY')
      ?.replace(/\\n/g, '\n');

    if (clientEmail && privateKey) {
      return initializeApp({
        credential: cert({ projectId, clientEmail, privateKey }),
      });
    }

    this.logger.warn(
      'Firebase Admin credentials not configured; relying on Application Default Credentials (GOOGLE_APPLICATION_CREDENTIALS).',
    );
    return initializeApp({ projectId });
  }
}
