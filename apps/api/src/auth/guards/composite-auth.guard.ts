import { ExecutionContext, Injectable } from '@nestjs/common';
import { AuthGuard } from './auth.guard';
import { DevAuthGuard } from './dev-auth.guard';
import { JwtAuthGuard } from './jwt-auth.guard';

/**
 * Development and test: accept a MeMy access JWT when present, otherwise
 * the existing X-Dev-User-Id flow. Production never uses this guard.
 */
@Injectable()
export class CompositeAuthGuard extends AuthGuard {
  constructor(
    private readonly jwt: JwtAuthGuard,
    private readonly dev: DevAuthGuard,
  ) {
    super();
  }

  canActivate(context: ExecutionContext) {
    const request = context.switchToHttp().getRequest<{
      headers: Record<string, string | string[] | undefined>;
    }>();
    const raw = request.headers.authorization ?? request.headers.Authorization;
    const value = Array.isArray(raw) ? raw[0] : raw;
    if (
      value &&
      /^Bearer\s+/i.test(value) &&
      !/^Bearer\s+dev(\s|:)/i.test(value)
    ) {
      return this.jwt.canActivate(context);
    }
    return this.dev.canActivate(context);
  }
}
