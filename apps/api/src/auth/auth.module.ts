import { Module } from '@nestjs/common';
import { APP_GUARD } from '@nestjs/core';
import { ConfigService } from '@nestjs/config';
import { DevAuthGuard } from './guards/dev-auth.guard';
import { JwtAuthGuard } from './guards/jwt-auth.guard';
import { CompositeAuthGuard } from './guards/composite-auth.guard';
import { AuthGuard } from './guards/auth.guard';
import { AuthService } from './auth.service';
import { AuthController } from './auth.controller';
import { MeController } from './me.controller';
import {
  APPLE_TOKEN_VERIFIER,
  GOOGLE_TOKEN_VERIFIER,
} from './identity/identity-token.verifier';
import { RejectingTokenVerifier } from './identity/rejecting-token.verifier';
import { GoogleTokenVerifier } from './identity/google-token.verifier';
import { AppleTokenVerifier } from './identity/apple-token.verifier';
import { AppConfig } from '../config/configuration';

@Module({
  controllers: [AuthController, MeController],
  providers: [
    AuthService,
    DevAuthGuard,
    JwtAuthGuard,
    CompositeAuthGuard,
    {
      provide: GOOGLE_TOKEN_VERIFIER,
      inject: [ConfigService],
      useFactory: (config: ConfigService<AppConfig, true>) => {
        const audience = config.get('auth', { infer: true }).googleClientId;
        if (!audience) {
          return new RejectingTokenVerifier('google');
        }
        return new GoogleTokenVerifier(audience);
      },
    },
    {
      provide: APPLE_TOKEN_VERIFIER,
      inject: [ConfigService],
      useFactory: (config: ConfigService<AppConfig, true>) => {
        const audience = config.get('auth', { infer: true }).appleClientId;
        if (!audience) {
          return new RejectingTokenVerifier('apple');
        }
        return new AppleTokenVerifier(audience);
      },
    },
    {
      provide: APP_GUARD,
      inject: [ConfigService, JwtAuthGuard, CompositeAuthGuard],
      useFactory: (
        config: ConfigService<AppConfig, true>,
        jwt: JwtAuthGuard,
        composite: CompositeAuthGuard,
      ): AuthGuard => {
        return config.get('nodeEnv', { infer: true }) === 'production'
          ? jwt
          : composite;
      },
    },
  ],
  exports: [AuthService, DevAuthGuard, JwtAuthGuard],
})
export class AuthModule {}
