import {
  ExecutionContext,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { Reflector } from '@nestjs/core';
import { AuthGuard } from './auth.guard';
import { AppConfig } from '../../config/configuration';
import { IS_PUBLIC_KEY } from '../decorators/public.decorator';

/**
 * Development-only authentication.
 *
 * Accepts either:
 * - Header `X-Dev-User-Id: <uuid>` matching DEV_USER_ID
 * - Header `Authorization: Bearer dev <uuid>` matching DEV_USER_ID
 *
 * Refuses to run when NODE_ENV=production.
 * Skips routes marked with @Public().
 */
@Injectable()
export class DevAuthGuard extends AuthGuard {
  constructor(
    private readonly config: ConfigService<AppConfig, true>,
    private readonly reflector: Reflector,
  ) {
    super();
  }

  canActivate(context: ExecutionContext): boolean {
    const isPublic = this.reflector.getAllAndOverride<boolean>(IS_PUBLIC_KEY, [
      context.getHandler(),
      context.getClass(),
    ]);
    if (isPublic) {
      return true;
    }

    const nodeEnv = this.config.get('nodeEnv', { infer: true });
    if (nodeEnv === 'production') {
      throw new UnauthorizedException({
        code: 'AUTH_PROVIDER_REQUIRED',
        message:
          'Development authentication is disabled in production. Configure a real auth provider.',
      });
    }

    const request = context.switchToHttp().getRequest<{
      headers: Record<string, string | string[] | undefined>;
    }>();
    const devUser = this.config.get('devUser', { infer: true });
    const headerId = this.readHeader(request.headers, 'x-dev-user-id');
    const bearer = this.readHeader(request.headers, 'authorization');
    const bearerId = this.parseDevBearer(bearer);

    const providedId = headerId ?? bearerId;
    if (!providedId || providedId !== devUser.id) {
      throw new UnauthorizedException({
        code: 'DEV_AUTH_REQUIRED',
        message:
          'Provide X-Dev-User-Id (or Authorization: Bearer dev <DEV_USER_ID>) matching the configured development user.',
      });
    }

    this.attachUser(context, {
      id: devUser.id,
      email: devUser.email,
      displayName: devUser.displayName,
      timezone: devUser.timezone,
      currencyCode: devUser.currencyCode,
      authMode: 'development',
    });
    return true;
  }

  private readHeader(
    headers: Record<string, string | string[] | undefined>,
    name: string,
  ): string | undefined {
    const value = headers[name] ?? headers[name.toLowerCase()];
    if (Array.isArray(value)) return value[0];
    return value;
  }

  private parseDevBearer(authorization?: string): string | undefined {
    if (!authorization) return undefined;
    const match = /^Bearer\s+dev(?:\s+|:)(.+)$/i.exec(authorization.trim());
    return match?.[1]?.trim();
  }
}
