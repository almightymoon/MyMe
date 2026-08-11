import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import configuration, { envValidationSchema } from './config/configuration';
import { AuthModule } from './auth/auth.module';
import { PrismaModule } from './prisma/prisma.module';
import { HealthModule } from './health/health.module';
import { GoalsModule } from './goals/goals.module';
import { TodayModule } from './today/today.module';
import { SyncModule } from './sync/sync.module';
import { AssetsModule } from './assets/assets.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      load: [configuration],
      validationSchema: envValidationSchema,
      validationOptions: {
        abortEarly: false,
        allowUnknown: true,
      },
    }),
    PrismaModule,
    AuthModule,
    HealthModule,
    GoalsModule,
    TodayModule,
    SyncModule,
    AssetsModule,
  ],
})
export class AppModule {}
