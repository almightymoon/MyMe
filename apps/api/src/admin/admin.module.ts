import { Module } from '@nestjs/common';
import { AuthModule } from '../auth/auth.module';
import { AdminAuthController } from './admin-auth.controller';
import { AdminAuthGuard } from './admin-auth.guard';
import { AdminAuthService } from './admin-auth.service';
import { AdminController } from './admin.controller';
import { AdminService } from './admin.service';

@Module({
  imports: [AuthModule],
  controllers: [AdminAuthController, AdminController],
  providers: [AdminAuthService, AdminService, AdminAuthGuard],
})
export class AdminModule {}
