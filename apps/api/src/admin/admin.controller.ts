import {
  Body,
  Controller,
  Get,
  Param,
  ParseUUIDPipe,
  Patch,
  Post,
  Query,
  UseGuards,
} from '@nestjs/common';
import { ApiTags } from '@nestjs/swagger';
import { Public } from '../auth/decorators/public.decorator';
import { AdminAuthGuard } from './admin-auth.guard';
import { CurrentAdmin } from './admin-current-user.decorator';
import { AdminService } from './admin.service';
import {
  AssignSubscriptionDto,
  AuditListQueryDto,
  CreateAdminUserDto,
  AdminUserListQueryDto,
  PatchSubscriptionDto,
  PatchUserStatusDto,
  UpsertPlanDto,
} from './dto/admin.dto';
import { AdminRequestUser } from './types/admin-request-user';

@ApiTags('admin')
@Public()
@UseGuards(AdminAuthGuard)
@Controller('admin')
export class AdminController {
  constructor(private readonly admin: AdminService) {}

  @Get('overview')
  overview() {
    return this.admin.overview();
  }

  @Get('users')
  listUsers(@Query() query: AdminUserListQueryDto) {
    return this.admin.listUsers(query);
  }

  @Get('users/:id')
  getUser(@Param('id', ParseUUIDPipe) id: string) {
    return this.admin.getUser(id);
  }

  @Patch('users/:id')
  patchUser(
    @CurrentAdmin() actor: AdminRequestUser,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() body: PatchUserStatusDto,
  ) {
    return this.admin.setUserStatus(actor, id, body.status);
  }

  @Post('users/:id/logout-all')
  logoutAll(
    @CurrentAdmin() actor: AdminRequestUser,
    @Param('id', ParseUUIDPipe) id: string,
  ) {
    return this.admin.logoutUser(actor, id);
  }

  @Post('users/:id/devices/:deviceId/revoke')
  revokeDevice(
    @CurrentAdmin() actor: AdminRequestUser,
    @Param('id', ParseUUIDPipe) id: string,
    @Param('deviceId', ParseUUIDPipe) deviceId: string,
  ) {
    return this.admin.revokeDevice(actor, id, deviceId);
  }

  @Post('users/:id/subscription')
  assignSubscription(
    @CurrentAdmin() actor: AdminRequestUser,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() body: AssignSubscriptionDto,
  ) {
    return this.admin.assignSubscription(actor, id, body);
  }

  @Get('plans')
  listPlans() {
    return this.admin.listPlans();
  }

  @Post('plans')
  upsertPlan(
    @CurrentAdmin() actor: AdminRequestUser,
    @Body() body: UpsertPlanDto,
  ) {
    return this.admin.upsertPlan(actor, body);
  }

  @Get('subscriptions')
  listSubscriptions(@Query() query: AuditListQueryDto) {
    return this.admin.listSubscriptions(query.page, query.pageSize);
  }

  @Patch('subscriptions/:id')
  patchSubscription(
    @CurrentAdmin() actor: AdminRequestUser,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() body: PatchSubscriptionDto,
  ) {
    return this.admin.patchSubscription(actor, id, body);
  }

  @Get('revenue')
  revenue() {
    return this.admin.revenue();
  }

  @Get('audit')
  audit(@Query() query: AuditListQueryDto) {
    return this.admin.listAudit(query.page, query.pageSize);
  }

  @Get('operators')
  listAdmins() {
    return this.admin.listAdmins();
  }

  @Post('operators')
  createAdmin(
    @CurrentAdmin() actor: AdminRequestUser,
    @Body() body: CreateAdminUserDto,
  ) {
    return this.admin.createAdmin(actor, body);
  }
}
