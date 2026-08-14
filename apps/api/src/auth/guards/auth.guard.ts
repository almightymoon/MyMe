import { CanActivate, ExecutionContext, Injectable } from '@nestjs/common';
import { RequestUser } from '../types/request-user';

/**
 * Abstract authentication guard.
 * Production providers (Firebase/Auth0) will replace DevAuthGuard.
 */
@Injectable()
export abstract class AuthGuard implements CanActivate {
  abstract canActivate(context: ExecutionContext): Promise<boolean> | boolean;

  protected attachUser(context: ExecutionContext, user: RequestUser): void {
    const request = context.switchToHttp().getRequest<{ user?: RequestUser }>();
    request.user = user;
  }
}
