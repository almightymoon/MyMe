import {
  Body,
  Controller,
  Delete,
  Get,
  HttpCode,
  HttpStatus,
  Param,
  ParseUUIDPipe,
  UnauthorizedException,
} from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { CurrentUser } from './decorators/current-user.decorator';
import { RequestUser } from './types/request-user';
import { AuthService } from './auth.service';
import { DeleteAccountDto } from './dto/auth.dto';

@ApiTags('me')
@ApiBearerAuth('access-token')
@Controller('me')
export class MeController {
  constructor(private readonly auth: AuthService) {}

  @Get()
  @ApiOperation({ summary: 'Current account profile' })
  getMe(@CurrentUser() user: RequestUser) {
    return this.auth.getMe(user.id);
  }

  @Get('devices')
  @ApiOperation({ summary: 'Devices with active sessions' })
  listDevices(@CurrentUser() user: RequestUser) {
    return this.auth.listDevices(user.id);
  }

  @Delete('devices/:deviceId')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ summary: 'Revoke one device and its refresh sessions' })
  async revokeDevice(
    @CurrentUser() user: RequestUser,
    @Param('deviceId', new ParseUUIDPipe({ version: '4' })) deviceId: string,
  ) {
    await this.auth.revokeDevice(user.id, deviceId);
  }

  @Get('export')
  @ApiOperation({
    summary: 'Export synchronized app-owned records for this account',
  })
  exportAccount(@CurrentUser() user: RequestUser) {
    return this.auth.exportAccount(user.id);
  }

  @Delete()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Delete this account and revoke all sessions' })
  async deleteAccount(
    @CurrentUser() user: RequestUser,
    @Body() body: DeleteAccountDto,
  ) {
    if (body.confirmation !== 'DELETE MY ACCOUNT') {
      throw new UnauthorizedException({
        code: 'DELETION_CONFIRMATION_REQUIRED',
        message: 'Type DELETE MY ACCOUNT to confirm.',
      });
    }
    await this.auth.deleteAccount(user.id);
    return { status: 'deleted' };
  }
}
