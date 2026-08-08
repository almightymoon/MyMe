import { Module } from '@nestjs/common';
import { GoalsModule } from '../goals/goals.module';
import { TodayController } from './today.controller';
import { TodayService } from './today.service';

@Module({
  imports: [GoalsModule],
  controllers: [TodayController],
  providers: [TodayService],
})
export class TodayModule {}
