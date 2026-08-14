import {
  Body,
  Controller,
  HttpCode,
  HttpStatus,
  Post,
  UsePipes,
  ValidationPipe,
} from '@nestjs/common';
import { ApiOperation, ApiTags } from '@nestjs/swagger';
import { Public } from './decorators/public.decorator';
import { CurrentUser } from './decorators/current-user.decorator';
import { RequestUser } from './types/request-user';
import { AuthService } from './auth.service';
import {
  AppleSignInDto,
  DeviceInfoDto,
  GoogleSignInDto,
  LogoutDto,
  RefreshDto,
} from './dto/auth.dto';

const bodyValidation = new ValidationPipe({
  transform: true,
  whitelist: true,
  forbidNonWhitelisted: true,
});

@ApiTags('auth')
@Controller('auth')
export class AuthController {
  constructor(private readonly auth: AuthService) {}

  @Public()
  @Post('google')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Sign in with a verified Google ID token' })
  @UsePipes(bodyValidation)
  async google(@Body() body: GoogleSignInDto) {
    return this.auth.signInWithGoogle(
      body.idToken,
      this.device(body.device),
      body.nonce,
    );
  }

  @Public()
  @Post('apple')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Sign in with a verified Apple identity token' })
  @UsePipes(bodyValidation)
  async apple(@Body() body: AppleSignInDto) {
    const displayName = [body.givenName, body.familyName]
      .filter(Boolean)
      .join(' ')
      .trim();
    return this.auth.signInWithApple(
      body.identityToken,
      this.device(body.device),
      body.nonce,
      displayName || undefined,
    );
  }

  @Public()
  @Post('refresh')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Rotate the opaque refresh token' })
  @UsePipes(bodyValidation)
  async refresh(@Body() body: RefreshDto) {
    return this.auth.refresh(body.refreshToken, this.device(body.device));
  }

  @Public()
  @Post('logout')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ summary: 'Revoke the current refresh session' })
  @UsePipes(bodyValidation)
  async logout(@Body() body: LogoutDto) {
    await this.auth.logout(body.refreshToken);
  }

  @Post('logout-all')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ summary: 'Revoke every refresh session for this account' })
  async logoutAll(@CurrentUser() user: RequestUser) {
    await this.auth.logoutAll(user.id);
  }

  private device(device: DeviceInfoDto) {
    return {
      clientGeneratedDeviceId: device.clientGeneratedDeviceId,
      platform: device.platform,
      appVersion: device.appVersion,
      deviceLabel: device.deviceLabel,
    };
  }
}
