import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Notification } from './notification.entity';

@Injectable()
export class NotificationRepository {
  constructor(
    @InjectRepository(Notification)
    private readonly repo: Repository<Notification>,
  ) {}

  create(data: Partial<Notification>): Notification {
    return this.repo.create(data);
  }

  save(notification: Notification): Promise<Notification> {
    return this.repo.save(notification);
  }

  findById(id: string): Promise<Notification | null> {
    return this.repo.findOneBy({ id });
  }

  findByUserId(userId: string): Promise<Notification[]> {
    return this.repo.find({
      where: { userId },
      order: { sentAt: 'DESC' },
    });
  }
}
