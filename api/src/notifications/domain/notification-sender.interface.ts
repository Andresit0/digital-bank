export interface NotificationDelivery {
  token: string;
  type: string;
  movementId: string;
}

export interface NotificationSender {
  send(delivery: NotificationDelivery): Promise<string>;
}
