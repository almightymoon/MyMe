import { Body, Controller, Get, Post, Query } from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { RequestUser } from '../auth/types/request-user';
import {
  SyncBootstrapQueryDto,
  SyncPullQueryDto,
  SyncPushDto,
} from './dto/sync.dto';
import { SyncService } from './sync.service';

@ApiTags('sync')
@ApiBearerAuth('access-token')
@Controller('sync')
export class SyncController {
  constructor(private readonly sync: SyncService) {}

  @Post('bootstrap')
  @ApiOperation({ summary: 'Return the current app-owned snapshot' })
  bootstrap(
    @CurrentUser() user: RequestUser,
    @Query() query: SyncBootstrapQueryDto,
  ) {
    return this.sync.bootstrap(user.id, query.limit, query.cursor);
  }

  @Post('push')
  @ApiOperation({ summary: 'Push a bounded batch of offline mutations' })
  push(@CurrentUser() user: RequestUser, @Body() body: SyncPushDto) {
    return this.sync.push(user.id, body);
  }

  @Get('pull')
  @ApiOperation({ summary: 'Pull ordered changes after the stored cursor' })
  pull(@CurrentUser() user: RequestUser, @Query() query: SyncPullQueryDto) {
    return this.sync.pull(user.id, query.cursor ?? '0', query.limit);
  }
}
