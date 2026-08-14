import { ApiProperty } from '@nestjs/swagger';
import { GoalResponseDto } from '../../goals/dto/goal-response.dto';

export class TodaySummaryDto {
  @ApiProperty({ description: 'Count of active (non-archived) goals' })
  activeGoalCount!: number;

  @ApiProperty({
    description: 'Active goals with deadline within the next 14 days',
    type: [GoalResponseDto],
  })
  goalsDueSoon!: GoalResponseDto[];

  @ApiProperty({
    description: 'Active goals whose forecast status is atRisk or overdue',
    type: [GoalResponseDto],
  })
  goalsAtRisk!: GoalResponseDto[];

  @ApiProperty({
    description: 'Top active goals by priority then soonest deadline',
    type: [GoalResponseDto],
  })
  topActiveGoals!: GoalResponseDto[];

  @ApiProperty({
    description: 'Average progressPercent across active goals',
    example: 42.5,
  })
  averageGoalProgress!: number;
}
