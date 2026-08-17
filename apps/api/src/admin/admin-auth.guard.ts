import {
  CanActivate,
  ExecutionContext,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { PrismaService } from '../prisma/prisma.service';
import { AppConfig } from '../config/configuration';
import { verifyAdminAccessToken } from './admin-crypto';
import { AdminRequestUser } from './types/admin-request-user';

@Injectable()
export class AdminAuthGuard implements CanActivate {
  constructor(
    private readonly config: ConfigService<AppConfig, true>,
    private readonly prisma: PrismaService,
  ) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest<{
      headers: Record<string, string | string[] | undefined>;
      adminUser?: AdminRequestUser;
    }>();
    const authorization = this.readHeader(request.headers, 'authorization');
    const token = this.parseBearer(authorization);
    if (!token) {
      throw new UnauthorizedException({
        code: 'ADMIN_AUTH_REQUIRED',
        message: 'Sign in to the admin panel.',
      });
    }

    let claims;
    try {
      claims = verifyAdminAccessToken(
        token,
        this.config.get('auth', { infer: true }).accessSecret,
      );
    } catch {
      throw new UnauthorizedException({
        code: 'ADMIN_TOKEN_INVALID',
        message: 'Sign in again.',
      });
    }

    const admin = await this.prisma.adminUser.findUnique({
      where: { id: claims.sub },
      select: {
        id: true,
        email: true,
        displayName: true,
        status: true,
      },
    });
    if (!admin || admin.status !== 'active') {
      throw new UnauthorizedException({
        code: 'ADMIN_UNAVAILABLE',
        message: 'This admin account is no longer available.',
      });
    }

    request.adminUser = {
      id: admin.id,
      email: admin.email,
      displayName: admin.displayName,
    };
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
    return match?.[1]?.trim();
  }
}
