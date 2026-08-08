import { Controller, Get } from '@nestjs/common';
import { ApiOperation, ApiProperty, ApiTags } from '@nestjs/swagger';
import { Public } from '../auth/decorators/public.decorator';
import { PrismaService } from '../prisma/prisma.service';

export class HealthResponseDto {
  @ApiProperty({ example: 'ok' })
  status!: 'ok' | 'degraded';

  @ApiProperty({ example: 'memy-api' })
  service!: string;

  @ApiProperty()
  timestamp!: string;

  @ApiProperty({ example: 'up' })
  database!: 'up' | 'down';

  @ApiProperty({ example: '0.0.1' })
  version!: string;
}

@ApiTags('health')
@Controller('health')
export class HealthController {
  constructor(private readonly prisma: PrismaService) {}

  @Public()
  @Get()
  @ApiOperation({ summary: 'Liveness / readiness health check' })
  async check(): Promise<HealthResponseDto> {
    let database: 'up' | 'down' = 'up';
    try {
      await this.prisma.$queryRaw`SELECT 1`;
    } catch {
      database = 'down';
    }

    return {
      status: database === 'up' ? 'ok' : 'degraded',
      service: 'memy-api',
      timestamp: new Date().toISOString(),
      database,
      version: process.env.npm_package_version ?? '0.0.1',
    };
  }
}
