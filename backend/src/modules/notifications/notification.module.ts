import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Notification } from './notification.entity';
import { NotificationController } from './notification.controller';
import { NotificationService } from './notification.service';
import { NotificationRepository } from './notification.repository';
import { ClientsModule } from '../clients/client.module';
import { FcmModule } from '../../integrations/fcm/fcm.module';

@Module({
  imports: [TypeOrmModule.forFeature([Notification]), ClientsModule, FcmModule],
  controllers: [NotificationController],
  providers: [NotificationService, NotificationRepository],
})
export class NotificationsModule {}
