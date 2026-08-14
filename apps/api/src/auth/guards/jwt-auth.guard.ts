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
import { PrismaService } from '../../prisma/prisma.service';
import { verifyAccessToken } from '../session/access-token';

/**
 * Production authentication. Accepts `Authorization: Bearer <access JWT>`.
 * Development startup continues to use DevAuthGuard instead.
 */
@Injectable()
export class JwtAuthGuard extends AuthGuard {
  constructor(
    private readonly config: ConfigService<AppConfig, true>,
    private readonly reflector: Reflector,
    private readonly prisma: PrismaService,
  ) {
    super();
  }

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const isPublic = this.reflector.getAllAndOverride<boolean>(IS_PUBLIC_KEY, [
      context.getHandler(),
      context.getClass(),
    ]);
    if (isPublic) {
      return true;
    }

    const request = context.switchToHttp().getRequest<{
      headers: Record<string, string | string[] | undefined>;
    }>();
    const authorization = this.readHeader(request.headers, 'authorization');
    const token = this.parseBearer(authorization);
    if (!token) {
      throw new UnauthorizedException({
        code: 'AUTH_REQUIRED',
        message: 'Sign in to continue.',
      });
    }

    let claims;
    try {
      claims = verifyAccessToken(
        token,
        this.config.get('auth', { infer: true }).accessSecret,
      );
    } catch {
      throw new UnauthorizedException({
        code: 'ACCESS_TOKEN_INVALID',
        message: 'Sign in again to sync.',
      });
    }

    const [user, device] = await Promise.all([
      this.prisma.user.findUnique({
        where: { id: claims.sub },
        select: {
          id: true,
          email: true,
          displayName: true,
          timezone: true,
          currencyCode: true,
          status: true,
          deletedAt: true,
        },
      }),
      this.prisma.device.findUnique({
        where: { id: claims.deviceId },
        select: { id: true, userId: true, revokedAt: true },
      }),
    ]);
    if (!user || user.deletedAt || user.status !== 'active') {
      throw new UnauthorizedException({
        code: 'ACCOUNT_UNAVAILABLE',
        message: 'This account is no longer available.',
      });
    }

    if (!device || device.userId !== user.id || device.revokedAt) {
      throw new UnauthorizedException({
        code: 'DEVICE_REVOKED',
        message: 'Sign in again to sync.',
      });
    }

    this.attachUser(context, {
      id: user.id,
      email: user.email,
      displayName: user.displayName,
      timezone: user.timezone,
      currencyCode: user.currencyCode,
      authMode: 'production',
      deviceId: device.id,
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

  private parseBearer(authorization?: string): string | undefined {
    if (!authorization) return undefined;
    const match = /^Bearer\s+(.+)$/i.exec(authorization.trim());
    const token = match?.[1]?.trim();
    if (!token || /^dev(\s|:)/i.test(token)) {
      return undefined;
    }
    return token;
  }
}
