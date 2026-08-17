import { createParamDecorator, ExecutionContext } from '@nestjs/common';
import { AdminRequestUser } from './types/admin-request-user';

export const CurrentAdmin = createParamDecorator(
  (_data: unknown, ctx: ExecutionContext): AdminRequestUser => {
    const request = ctx.switchToHttp().getRequest<{
      adminUser?: AdminRequestUser;
    }>();
    if (!request.adminUser) {
      throw new Error('ADMIN_USER_MISSING');
    }
    return request.adminUser;
  },
);
