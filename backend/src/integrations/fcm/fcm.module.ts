import { Module } from '@nestjs/common';
import { FcmClient } from './fcm.client';

@Module({
  providers: [FcmClient],
  exports: [FcmClient],
})
export class FcmModule {}
