import { Module } from '@nestjs/common';
import { APP_GUARD } from '@nestjs/core';
import { DevAuthGuard } from './guards/dev-auth.guard';

@Module({
  providers: [
    DevAuthGuard,
    {
      provide: APP_GUARD,
      useClass: DevAuthGuard,
    },
  ],
  exports: [DevAuthGuard],
})
export class AuthModule {}
