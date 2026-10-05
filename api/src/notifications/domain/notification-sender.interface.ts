export interface NotificationDelivery {
  token: string;
  type: string;
  movementId: string;
  title: string;
  body: string;
}

export interface NotificationSender {
  send(delivery: NotificationDelivery): Promise<string>;
}
