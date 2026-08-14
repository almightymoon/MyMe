import {
  Body,
  Controller,
  Delete,
  Get,
  HttpCode,
  HttpStatus,
  Param,
  ParseUUIDPipe,
  Patch,
  Post,
  Query,
} from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiHeader,
  ApiOperation,
  ApiResponse,
  ApiTags,
} from '@nestjs/swagger';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { RequestUser } from '../auth/types/request-user';
import {
  CreateGoalDto,
  CreateMilestoneDto,
  ListGoalsQueryDto,
  RecordProgressDto,
  UpdateGoalDto,
  UpdateMilestoneDto,
} from './dto/goal.dto';
import {
  GoalResponseDto,
  MilestoneCreateResponseDto,
} from './dto/goal-response.dto';
import { GoalsService } from './goals.service';

@ApiTags('goals')
@ApiHeader({
  name: 'X-Dev-User-Id',
  description:
    'Development authentication. Must equal DEV_USER_ID. Alternative: Authorization: Bearer dev <DEV_USER_ID>',
  required: true,
})
@ApiBearerAuth('dev-auth')
@Controller('goals')
export class GoalsController {
  constructor(private readonly goalsService: GoalsService) {}

  @Get()
  @ApiOperation({ summary: 'List goals for the current user' })
  @ApiResponse({ status: 200, type: [GoalResponseDto] })
  list(
    @CurrentUser() user: RequestUser,
    @Query() query: ListGoalsQueryDto,
  ): Promise<GoalResponseDto[]> {
    return this.goalsService.list(user.id, query);
  }

  @Post()
  @ApiOperation({
    summary: 'Create a goal (optionally with initial milestones, atomically)',
  })
  @ApiResponse({ status: 201, type: GoalResponseDto })
  create(
    @CurrentUser() user: RequestUser,
    @Body() dto: CreateGoalDto,
  ): Promise<GoalResponseDto> {
    return this.goalsService.create(user.id, dto);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get a goal by id (includes progress history)' })
  @ApiResponse({ status: 200, type: GoalResponseDto })
  getOne(
    @CurrentUser() user: RequestUser,
    @Param('id', ParseUUIDPipe) id: string,
  ): Promise<GoalResponseDto> {
    return this.goalsService.getById(user.id, id, true);
  }

  @Patch(':id')
  @ApiOperation({ summary: 'Update a goal' })
  update(
    @CurrentUser() user: RequestUser,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: UpdateGoalDto,
  ): Promise<GoalResponseDto> {
    return this.goalsService.update(user.id, id, dto);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ summary: 'Delete a goal' })
  async remove(
    @CurrentUser() user: RequestUser,
    @Param('id', ParseUUIDPipe) id: string,
  ): Promise<void> {
    await this.goalsService.remove(user.id, id);
  }

  @Post(':id/archive')
  @ApiOperation({ summary: 'Archive a goal' })
  archive(
    @CurrentUser() user: RequestUser,
    @Param('id', ParseUUIDPipe) id: string,
  ): Promise<GoalResponseDto> {
    return this.goalsService.archive(user.id, id);
  }

  @Post(':id/progress')
  @ApiOperation({ summary: 'Record a progress entry and update the goal' })
  recordProgress(
    @CurrentUser() user: RequestUser,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: RecordProgressDto,
  ): Promise<GoalResponseDto> {
    return this.goalsService.recordProgress(user.id, id, dto);
  }

  @Post(':goalId/milestones')
  @ApiOperation({
    summary: 'Add a milestone to a goal',
    description:
      'Returns the updated goal plus the exact created milestone (duplicate titles are allowed).',
  })
  @ApiResponse({ status: 201, type: MilestoneCreateResponseDto })
  addMilestone(
    @CurrentUser() user: RequestUser,
    @Param('goalId', ParseUUIDPipe) goalId: string,
    @Body() dto: CreateMilestoneDto,
  ): Promise<MilestoneCreateResponseDto> {
    return this.goalsService.addMilestone(user.id, goalId, dto);
  }

  @Patch(':goalId/milestones/:milestoneId')
  @ApiOperation({ summary: 'Update a milestone' })
  updateMilestone(
    @CurrentUser() user: RequestUser,
    @Param('goalId', ParseUUIDPipe) goalId: string,
    @Param('milestoneId', ParseUUIDPipe) milestoneId: string,
    @Body() dto: UpdateMilestoneDto,
  ): Promise<GoalResponseDto> {
    return this.goalsService.updateMilestone(user.id, goalId, milestoneId, dto);
  }

  @Delete(':goalId/milestones/:milestoneId')
  @ApiOperation({ summary: 'Delete a milestone' })
  deleteMilestone(
    @CurrentUser() user: RequestUser,
    @Param('goalId', ParseUUIDPipe) goalId: string,
    @Param('milestoneId', ParseUUIDPipe) milestoneId: string,
  ): Promise<GoalResponseDto> {
    return this.goalsService.deleteMilestone(user.id, goalId, milestoneId);
  }

  @Post(':goalId/milestones/:milestoneId/complete')
  @ApiOperation({ summary: 'Mark a milestone complete' })
  completeMilestone(
    @CurrentUser() user: RequestUser,
    @Param('goalId', ParseUUIDPipe) goalId: string,
    @Param('milestoneId', ParseUUIDPipe) milestoneId: string,
  ): Promise<GoalResponseDto> {
    return this.goalsService.completeMilestone(user.id, goalId, milestoneId);
  }

  @Post(':goalId/milestones/:milestoneId/reopen')
  @ApiOperation({ summary: 'Reopen a completed milestone' })
  reopenMilestone(
    @CurrentUser() user: RequestUser,
    @Param('goalId', ParseUUIDPipe) goalId: string,
    @Param('milestoneId', ParseUUIDPipe) milestoneId: string,
  ): Promise<GoalResponseDto> {
    return this.goalsService.reopenMilestone(user.id, goalId, milestoneId);
  }
}
