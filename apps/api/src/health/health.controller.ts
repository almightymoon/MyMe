import {
  Controller,
  Get,
  HttpCode,
  HttpStatus,
  ServiceUnavailableException,
} from '@nestjs/common';
import {
  ApiOkResponse,
  ApiOperation,
  ApiProperty,
  ApiServiceUnavailableResponse,
  ApiTags,
} from '@nestjs/swagger';
import { Public } from '../auth/decorators/public.decorator';
import { PrismaService } from '../prisma/prisma.service';

export class HealthResponseDto {
  @ApiProperty({ example: 'ok', enum: ['ok', 'degraded'] })
  status!: 'ok' | 'degraded';

  @ApiProperty({ example: 'memy-api' })
  service!: string;

  @ApiProperty()
  timestamp!: string;

  @ApiProperty({ example: 'up', enum: ['up', 'down'] })
  database!: 'up' | 'down';

  @ApiProperty({ example: '0.0.1' })
  version!: string;
}

@ApiTags('health')
@Controller('health')
export class HealthController {
  constructor(private readonly prisma: PrismaService) {}

  @Public()
  @Get('live')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Liveness probe (no database)' })
  live(): Pick<HealthResponseDto, 'status' | 'service'> {
    return { status: 'ok', service: 'memy-api' };
  }

  @Public()
  @Get()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Readiness health check (503 when database is unreachable)',
  })
  @ApiOkResponse({ type: HealthResponseDto })
  @ApiServiceUnavailableResponse({
    description: 'Database unreachable — body includes standard error envelope',
  })
  async check(): Promise<HealthResponseDto> {
    let database: 'up' | 'down' = 'up';
    try {
      await this.prisma.$queryRaw`SELECT 1`;
    } catch {
      database = 'down';
    }

    const body: HealthResponseDto = {
      status: database === 'up' ? 'ok' : 'degraded',
      service: 'memy-api',
      timestamp: new Date().toISOString(),
      database,
      version: process.env.npm_package_version ?? '0.0.1',
    };

    if (database === 'down') {
      throw new ServiceUnavailableException({
        code: 'DATABASE_UNAVAILABLE',
        message: 'Database is unreachable',
        details: body,
      });
    }

    return body;
  }
}
