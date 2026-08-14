import { Controller, Get } from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiHeader,
  ApiOperation,
  ApiTags,
} from '@nestjs/swagger';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { RequestUser } from '../auth/types/request-user';
import { TodaySummaryDto } from './dto/today-summary.dto';
import { TodayService } from './today.service';

@ApiTags('today')
@ApiHeader({
  name: 'X-Dev-User-Id',
  required: true,
  description: 'Development authentication header',
})
@ApiBearerAuth('dev-auth')
@Controller('today')
export class TodayController {
  constructor(private readonly todayService: TodayService) {}

  @Get()
  @ApiOperation({
    summary: 'Today goal summary (active count, due soon, at risk, top goals)',
  })
  getToday(@CurrentUser() user: RequestUser): Promise<TodaySummaryDto> {
    return this.todayService.getSummary(user.id);
  }
}
