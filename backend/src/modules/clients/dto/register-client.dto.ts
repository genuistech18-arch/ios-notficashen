import { IsString, MinLength } from 'class-validator';

export class RegisterClientDto {
  @IsString()
  @MinLength(4)
  code: string;

  @IsString()
  @MinLength(1)
  fcm_token: string;
}
