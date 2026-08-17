import {
  Injectable,
  Logger,
  OnModuleInit,
  UnauthorizedException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { PrismaService } from '../prisma/prisma.service';
import { AppConfig } from '../config/configuration';
import {
  hashPassword,
  signAdminAccessToken,
  verifyPassword,
} from './admin-crypto';
import { AdminRequestUser } from './types/admin-request-user';

const ACCESS_TTL_SECONDS = 8 * 60 * 60;
const LOGIN_WINDOW_MS = 15 * 60 * 1000;
const LOGIN_MAX_ATTEMPTS = 8;

@Injectable()
export class AdminAuthService implements OnModuleInit {
  private readonly logger = new Logger(AdminAuthService.name);
  private readonly attempts = new Map<
    string,
    { count: number; resetAt: number }
  >();

  constructor(
    private readonly prisma: PrismaService,
    private readonly config: ConfigService<AppConfig, true>,
  ) {}

  async onModuleInit(): Promise<void> {
    const bootstrap = this.config.get('admin', { infer: true });
    if (!bootstrap.bootstrapEmail || !bootstrap.bootstrapPassword) {
      return;
    }
    try {
      const existing = await this.prisma.adminUser.count();
      if (existing > 0) {
        return;
      }
      const email = bootstrap.bootstrapEmail.toLowerCase();
      await this.prisma.adminUser.create({
        data: {
          email,
          displayName: 'Owner',
          passwordHash: hashPassword(bootstrap.bootstrapPassword),
          status: 'active',
        },
      });
      this.logger.warn(`Bootstrapped first admin account for ${email}`);
    } catch (error) {
      const code =
        typeof error === 'object' && error && 'code' in error
          ? String((error as { code?: string }).code)
          : '';
      if (code === 'P2021') {
        this.logger.warn(
          'Admin bootstrap skipped until prisma migrations are applied.',
        );
        return;
      }
      throw error;
    }
  }

  async login(email: string, password: string) {
    const key = email.trim().toLowerCase();
    this.assertRateLimit(key);
    const admin = await this.prisma.adminUser.findUnique({
      where: { email: key },
    });
    const ok =
      !!admin &&
      admin.status === 'active' &&
      verifyPassword(password, admin.passwordHash);
    if (!ok) {
      this.recordFailure(key);
      throw new UnauthorizedException({
        code: 'ADMIN_LOGIN_FAILED',
        message: 'Email or password is incorrect.',
      });
    }
    this.attempts.delete(key);
    await this.prisma.adminUser.update({
      where: { id: admin.id },
      data: { lastLoginAt: new Date() },
    });
    const { token, expiresAt } = signAdminAccessToken(
      { sub: admin.id, ver: 1 },
      this.config.get('auth', { infer: true }).accessSecret,
      ACCESS_TTL_SECONDS,
    );
    return {
      accessToken: token,
      expiresAt: expiresAt.toISOString(),
      admin: {
        id: admin.id,
        email: admin.email,
        displayName: admin.displayName,
      },
    };
  }

  me(admin: AdminRequestUser) {
    return admin;
  }

  private assertRateLimit(key: string) {
    const now = Date.now();
    const entry = this.attempts.get(key);
    if (!entry || entry.resetAt <= now) {
      return;
    }
    if (entry.count >= LOGIN_MAX_ATTEMPTS) {
      throw new UnauthorizedException({
        code: 'ADMIN_LOGIN_THROTTLED',
        message: 'Too many sign-in attempts. Try again later.',
      });
    }
  }

  private recordFailure(key: string) {
    const now = Date.now();
    const entry = this.attempts.get(key);
    if (!entry || entry.resetAt <= now) {
      this.attempts.set(key, { count: 1, resetAt: now + LOGIN_WINDOW_MS });
      return;
    }
    entry.count += 1;
  }
}
