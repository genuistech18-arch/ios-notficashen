import { IsString, MinLength } from 'class-validator';

export class SendNotificationDto {
  @IsString()
  @MinLength(4)
  code: string;

  @IsString()
  @MinLength(1)
  message: string;
}
