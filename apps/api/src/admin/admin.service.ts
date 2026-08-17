import {
  BadRequestException,
  ConflictException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import {
  PlanInterval,
  Prisma,
  SubscriptionStatus,
  UserStatus,
} from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { AuthService } from '../auth/auth.service';
import { AdminRequestUser } from './types/admin-request-user';
import { hashPassword } from './admin-crypto';

const ACTIVE_SUB_STATUSES: SubscriptionStatus[] = ['trialing', 'active'];

function money(value: Prisma.Decimal | string | number | bigint): string {
  return value.toString();
}

function monthlyMinor(interval: PlanInterval, amount: Prisma.Decimal): bigint {
  const n = BigInt(amount.toFixed(0));
  if (interval === 'year') {
    return n / 12n;
  }
  if (interval === 'month') {
    return n;
  }
  return 0n;
}

@Injectable()
export class AdminService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly auth: AuthService,
  ) {}

  async overview() {
    const now = new Date();
    const dayAgo = new Date(now.getTime() - 24 * 60 * 60 * 1000);
    const weekAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
    const monthAgo = new Date(now.getTime() - 30 * 24 * 60 * 60 * 1000);

    const [
      usersTotal,
      usersActive,
      usersDisabled,
      usersPendingDelete,
      signups7d,
      signups30d,
      signedIn24h,
      devicesActive,
      sessionsActive,
      paidSubs,
      recentUsers,
      recentAudit,
    ] = await Promise.all([
      this.prisma.user.count(),
      this.prisma.user.count({ where: { status: 'active', deletedAt: null } }),
      this.prisma.user.count({ where: { status: 'disabled' } }),
      this.prisma.user.count({ where: { status: 'deletionPending' } }),
      this.prisma.user.count({ where: { createdAt: { gte: weekAgo } } }),
      this.prisma.user.count({ where: { createdAt: { gte: monthAgo } } }),
      this.prisma.user.count({
        where: { lastSignedInAt: { gte: dayAgo } },
      }),
      this.prisma.device.count({ where: { revokedAt: null } }),
      this.prisma.refreshSession.count({
        where: { revokedAt: null, expiresAt: { gt: now } },
      }),
      this.prisma.subscription.findMany({
        where: { status: { in: ACTIVE_SUB_STATUSES } },
        include: { plan: true },
      }),
      this.prisma.user.findMany({
        orderBy: { createdAt: 'desc' },
        take: 8,
        select: {
          id: true,
          email: true,
          displayName: true,
          status: true,
          createdAt: true,
          lastSignedInAt: true,
        },
      }),
      this.prisma.adminAuditEvent.findMany({
        orderBy: { createdAt: 'desc' },
        take: 12,
        include: {
          adminUser: { select: { email: true, displayName: true } },
        },
      }),
    ]);

    let mrrMinor = 0n;
    const currency = paidSubs[0]?.currencyCode ?? 'PKR';
    for (const sub of paidSubs) {
      mrrMinor += monthlyMinor(sub.plan.interval, sub.amountMinor);
    }

    return {
      users: {
        total: usersTotal,
        active: usersActive,
        disabled: usersDisabled,
        deletionPending: usersPendingDelete,
        signups7d,
        signups30d,
        signedIn24h,
      },
      devices: { active: devicesActive },
      sessions: { active: sessionsActive },
      revenue: {
        currency,
        activePaidSubscriptions: paidSubs.filter(
          (s) => s.plan.interval !== 'none' && s.amountMinor.gt(0),
        ).length,
        mrrMinor: mrrMinor.toString(),
        arrMinor: (mrrMinor * 12n).toString(),
      },
      recentUsers,
      recentAudit: recentAudit.map((event) => ({
        id: event.id,
        action: event.action,
        targetType: event.targetType,
        targetId: event.targetId,
        createdAt: event.createdAt,
        admin: event.adminUser,
      })),
    };
  }

  async listUsers(query: {
    q?: string;
    status?: UserStatus;
    page?: number;
    pageSize?: number;
  }) {
    const page = query.page ?? 1;
    const pageSize = query.pageSize ?? 25;
    const where: Prisma.UserWhereInput = {};
    if (query.status) {
      where.status = query.status;
    }
    if (query.q?.trim()) {
      const q = query.q.trim();
      where.OR = [
        { email: { contains: q, mode: 'insensitive' } },
        { displayName: { contains: q, mode: 'insensitive' } },
        { id: q },
      ];
    }
    const [total, rows] = await this.prisma.$transaction([
      this.prisma.user.count({ where }),
      this.prisma.user.findMany({
        where,
        orderBy: { createdAt: 'desc' },
        skip: (page - 1) * pageSize,
        take: pageSize,
        select: {
          id: true,
          email: true,
          displayName: true,
          status: true,
          timezone: true,
          currencyCode: true,
          createdAt: true,
          lastSignedInAt: true,
          deletedAt: true,
          identities: {
            select: { provider: true, providerEmail: true, lastUsedAt: true },
          },
          _count: {
            select: { devices: true, sessions: true, subscriptions: true },
          },
          subscriptions: {
            where: { status: { in: ACTIVE_SUB_STATUSES } },
            take: 1,
            orderBy: { createdAt: 'desc' },
            include: { plan: true },
          },
        },
      }),
    ]);
    return {
      page,
      pageSize,
      total,
      items: rows.map((user) => ({
        id: user.id,
        email: user.email,
        displayName: user.displayName,
        status: user.status,
        timezone: user.timezone,
        currencyCode: user.currencyCode,
        createdAt: user.createdAt,
        lastSignedInAt: user.lastSignedInAt,
        deletedAt: user.deletedAt,
        identities: user.identities,
        deviceCount: user._count.devices,
        sessionCount: user._count.sessions,
        subscription: user.subscriptions[0]
          ? {
              id: user.subscriptions[0].id,
              status: user.subscriptions[0].status,
              plan: user.subscriptions[0].plan.name,
              amountMinor: money(user.subscriptions[0].amountMinor),
              currencyCode: user.subscriptions[0].currencyCode,
            }
          : null,
      })),
    };
  }

  async getUser(userId: string) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      include: {
        identities: true,
        devices: { orderBy: { lastSeenAt: 'desc' } },
        sessions: {
          where: { revokedAt: null },
          orderBy: { lastUsedAt: 'desc' },
          take: 20,
        },
        subscriptions: {
          include: { plan: true },
          orderBy: { createdAt: 'desc' },
        },
        _count: {
          select: {
            goals: true,
            syncRecords: true,
            assets: true,
            auditEvents: true,
          },
        },
      },
    });
    if (!user) {
      throw new NotFoundException({
        code: 'USER_NOT_FOUND',
        message: 'User not found.',
      });
    }
    return {
      id: user.id,
      email: user.email,
      displayName: user.displayName,
      status: user.status,
      timezone: user.timezone,
      currencyCode: user.currencyCode,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
      lastSignedInAt: user.lastSignedInAt,
      deletedAt: user.deletedAt,
      identities: user.identities,
      devices: user.devices,
      sessions: user.sessions.map((session) => ({
        id: session.id,
        deviceId: session.deviceId,
        createdAt: session.createdAt,
        expiresAt: session.expiresAt,
        lastUsedAt: session.lastUsedAt,
      })),
      subscriptions: user.subscriptions.map((sub) => ({
        id: sub.id,
        status: sub.status,
        amountMinor: money(sub.amountMinor),
        currencyCode: sub.currencyCode,
        startedAt: sub.startedAt,
        currentPeriodEnd: sub.currentPeriodEnd,
        canceledAt: sub.canceledAt,
        notes: sub.notes,
        plan: {
          id: sub.plan.id,
          code: sub.plan.code,
          name: sub.plan.name,
          interval: sub.plan.interval,
        },
      })),
      counts: user._count,
    };
  }

  async setUserStatus(
    admin: AdminRequestUser,
    userId: string,
    status: 'active' | 'disabled',
  ) {
    const user = await this.prisma.user.findUnique({ where: { id: userId } });
    if (!user) {
      throw new NotFoundException({
        code: 'USER_NOT_FOUND',
        message: 'User not found.',
      });
    }
    const updated = await this.prisma.user.update({
      where: { id: userId },
      data: { status },
    });
    if (status === 'disabled') {
      await this.auth.logoutAll(userId);
    }
    await this.audit(admin.id, 'user.status', 'user', userId, {
      from: user.status,
      to: status,
    });
    return { id: updated.id, status: updated.status };
  }

  async logoutUser(admin: AdminRequestUser, userId: string) {
    await this.ensureUser(userId);
    await this.auth.logoutAll(userId);
    await this.audit(admin.id, 'user.logout_all', 'user', userId, {});
    return { ok: true };
  }

  async revokeDevice(
    admin: AdminRequestUser,
    userId: string,
    deviceId: string,
  ) {
    const device = await this.prisma.device.findFirst({
      where: { id: deviceId, userId },
    });
    if (!device) {
      throw new NotFoundException({
        code: 'DEVICE_NOT_FOUND',
        message: 'Device not found.',
      });
    }
    const now = new Date();
    await this.prisma.$transaction([
      this.prisma.device.update({
        where: { id: deviceId },
        data: { revokedAt: now },
      }),
      this.prisma.refreshSession.updateMany({
        where: { deviceId, revokedAt: null },
        data: { revokedAt: now },
      }),
    ]);
    await this.audit(admin.id, 'user.revoke_device', 'device', deviceId, {
      userId,
    });
    return { ok: true };
  }

  async listPlans() {
    const plans = await this.prisma.plan.findMany({
      orderBy: { amountMinor: 'asc' },
      include: {
        _count: {
          select: {
            subscriptions: { where: { status: { in: ACTIVE_SUB_STATUSES } } },
          },
        },
      },
    });
    return plans.map((plan) => ({
      id: plan.id,
      code: plan.code,
      name: plan.name,
      interval: plan.interval,
      amountMinor: money(plan.amountMinor),
      currencyCode: plan.currencyCode,
      active: plan.active,
      activeSubscriptions: plan._count.subscriptions,
    }));
  }

  async upsertPlan(
    admin: AdminRequestUser,
    body: {
      code: string;
      name: string;
      interval: PlanInterval;
      amountMinor: string;
      currencyCode: string;
      active?: boolean;
    },
  ) {
    if (!/^\d+$/.test(body.amountMinor)) {
      throw new BadRequestException({
        code: 'PLAN_AMOUNT_INVALID',
        message: 'amountMinor must be a whole-number string.',
      });
    }
    const plan = await this.prisma.plan.upsert({
      where: { code: body.code },
      create: {
        code: body.code,
        name: body.name,
        interval: body.interval,
        amountMinor: body.amountMinor,
        currencyCode: body.currencyCode.toUpperCase(),
        active: body.active ?? true,
      },
      update: {
        name: body.name,
        interval: body.interval,
        amountMinor: body.amountMinor,
        currencyCode: body.currencyCode.toUpperCase(),
        active: body.active ?? true,
      },
    });
    await this.audit(admin.id, 'plan.upsert', 'plan', plan.id, {
      code: plan.code,
    });
    return {
      id: plan.id,
      code: plan.code,
      name: plan.name,
      interval: plan.interval,
      amountMinor: money(plan.amountMinor),
      currencyCode: plan.currencyCode,
      active: plan.active,
    };
  }

  async assignSubscription(
    admin: AdminRequestUser,
    userId: string,
    body: { planId: string; status?: 'trialing' | 'active'; notes?: string },
  ) {
    await this.ensureUser(userId);
    const plan = await this.prisma.plan.findUnique({
      where: { id: body.planId },
    });
    if (!plan || !plan.active) {
      throw new NotFoundException({
        code: 'PLAN_NOT_FOUND',
        message: 'Plan not found or inactive.',
      });
    }
    const now = new Date();
    const periodEnd =
      plan.interval === 'year'
        ? new Date(now.getTime() + 365 * 24 * 60 * 60 * 1000)
        : plan.interval === 'month'
          ? new Date(now.getTime() + 30 * 24 * 60 * 60 * 1000)
          : null;
    await this.prisma.subscription.updateMany({
      where: { userId, status: { in: ACTIVE_SUB_STATUSES } },
      data: { status: 'canceled', canceledAt: now },
    });
    const sub = await this.prisma.subscription.create({
      data: {
        userId,
        planId: plan.id,
        status: body.status ?? 'active',
        amountMinor: plan.amountMinor,
        currencyCode: plan.currencyCode,
        startedAt: now,
        currentPeriodEnd: periodEnd,
        notes: body.notes ?? '',
      },
      include: { plan: true },
    });
    await this.audit(admin.id, 'subscription.assign', 'subscription', sub.id, {
      userId,
      plan: plan.code,
    });
    return this.serializeSubscription(sub);
  }

  async patchSubscription(
    admin: AdminRequestUser,
    subscriptionId: string,
    body: { status?: SubscriptionStatus; notes?: string },
  ) {
    const existing = await this.prisma.subscription.findUnique({
      where: { id: subscriptionId },
    });
    if (!existing) {
      throw new NotFoundException({
        code: 'SUBSCRIPTION_NOT_FOUND',
        message: 'Subscription not found.',
      });
    }
    const sub = await this.prisma.subscription.update({
      where: { id: subscriptionId },
      data: {
        status: body.status,
        notes: body.notes,
        canceledAt:
          body.status === 'canceled' || body.status === 'expired'
            ? new Date()
            : existing.canceledAt,
      },
      include: { plan: true },
    });
    await this.audit(
      admin.id,
      'subscription.patch',
      'subscription',
      subscriptionId,
      body,
    );
    return this.serializeSubscription(sub);
  }

  async listSubscriptions(page = 1, pageSize = 25) {
    const where = {};
    const [total, rows] = await this.prisma.$transaction([
      this.prisma.subscription.count({ where }),
      this.prisma.subscription.findMany({
        where,
        orderBy: { createdAt: 'desc' },
        skip: (page - 1) * pageSize,
        take: pageSize,
        include: {
          plan: true,
          user: {
            select: { id: true, email: true, displayName: true, status: true },
          },
        },
      }),
    ]);
    return {
      page,
      pageSize,
      total,
      items: rows.map((row) => ({
        ...this.serializeSubscription(row),
        user: row.user,
      })),
    };
  }

  async revenue() {
    const subs = await this.prisma.subscription.findMany({
      where: { status: { in: ACTIVE_SUB_STATUSES } },
      include: { plan: true },
    });
    const byPlan: Record<
      string,
      { plan: string; count: number; mrrMinor: bigint; currencyCode: string }
    > = {};
    let mrr = 0n;
    for (const sub of subs) {
      const monthly = monthlyMinor(sub.plan.interval, sub.amountMinor);
      mrr += monthly;
      const key = sub.plan.code;
      if (!byPlan[key]) {
        byPlan[key] = {
          plan: sub.plan.name,
          count: 0,
          mrrMinor: 0n,
          currencyCode: sub.currencyCode,
        };
      }
      byPlan[key].count += 1;
      byPlan[key].mrrMinor += monthly;
    }
    return {
      mrrMinor: mrr.toString(),
      arrMinor: (mrr * 12n).toString(),
      activeSubscriptions: subs.length,
      byPlan: Object.values(byPlan).map((row) => ({
        ...row,
        mrrMinor: row.mrrMinor.toString(),
      })),
    };
  }

  async listAudit(page = 1, pageSize = 40) {
    const [total, rows] = await this.prisma.$transaction([
      this.prisma.adminAuditEvent.count(),
      this.prisma.adminAuditEvent.findMany({
        orderBy: { createdAt: 'desc' },
        skip: (page - 1) * pageSize,
        take: pageSize,
        include: {
          adminUser: { select: { email: true, displayName: true } },
        },
      }),
    ]);
    return { page, pageSize, total, items: rows };
  }

  async createAdmin(
    actor: AdminRequestUser,
    body: { email: string; displayName: string; password: string },
  ) {
    const email = body.email.trim().toLowerCase();
    try {
      const created = await this.prisma.adminUser.create({
        data: {
          email,
          displayName: body.displayName.trim(),
          passwordHash: hashPassword(body.password),
        },
        select: {
          id: true,
          email: true,
          displayName: true,
          status: true,
          createdAt: true,
        },
      });
      await this.audit(actor.id, 'admin.create', 'admin', created.id, {
        email,
      });
      return created;
    } catch (error) {
      if (
        error instanceof Prisma.PrismaClientKnownRequestError &&
        error.code === 'P2002'
      ) {
        throw new ConflictException({
          code: 'ADMIN_EMAIL_TAKEN',
          message: 'An operator with that email already exists.',
        });
      }
      throw error;
    }
  }

  async listAdmins() {
    return this.prisma.adminUser.findMany({
      orderBy: { createdAt: 'asc' },
      select: {
        id: true,
        email: true,
        displayName: true,
        status: true,
        lastLoginAt: true,
        createdAt: true,
      },
    });
  }

  private serializeSubscription(sub: {
    id: string;
    status: SubscriptionStatus;
    amountMinor: Prisma.Decimal;
    currencyCode: string;
    startedAt: Date;
    currentPeriodEnd: Date | null;
    canceledAt: Date | null;
    notes: string;
    plan: { id: string; code: string; name: string; interval: PlanInterval };
  }) {
    return {
      id: sub.id,
      status: sub.status,
      amountMinor: money(sub.amountMinor),
      currencyCode: sub.currencyCode,
      startedAt: sub.startedAt,
      currentPeriodEnd: sub.currentPeriodEnd,
      canceledAt: sub.canceledAt,
      notes: sub.notes,
      plan: sub.plan,
    };
  }

  private async ensureUser(userId: string) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: { id: true },
    });
    if (!user) {
      throw new NotFoundException({
        code: 'USER_NOT_FOUND',
        message: 'User not found.',
      });
    }
  }

  private async audit(
    adminUserId: string,
    action: string,
    targetType: string,
    targetId: string | null,
    metadata: Prisma.InputJsonValue,
  ) {
    await this.prisma.adminAuditEvent.create({
      data: { adminUserId, action, targetType, targetId, metadata },
    });
  }
}
