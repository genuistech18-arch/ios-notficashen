import {
  Body,
  Controller,
  Get,
  Param,
  Patch,
  Post,
  UseGuards,
} from '@nestjs/common';
import { SkipThrottle } from '@nestjs/throttler';
import { NotificationService } from './notification.service';
import { SendNotificationDto } from './dto/send-notification.dto';
import { ApiKeyGuard } from '../../common/guards/api-key.guard';

@Controller('api/v1')
@SkipThrottle({ register: true })
export class NotificationController {
  constructor(private readonly notificationService: NotificationService) {}

  @Post('notifications/send')
  @UseGuards(ApiKeyGuard)
  send(@Body() dto: SendNotificationDto) {
    return this.notificationService.sendNotification(dto.code, dto.message);
  }

  @Get('clients/:code/notifications')
  getHistory(@Param('code') code: string) {
    return this.notificationService.getHistoryForCode(code);
  }

  @Patch('notifications/:id/read')
  markRead(@Param('id') id: string) {
    return this.notificationService.markRead(id);
  }
}
