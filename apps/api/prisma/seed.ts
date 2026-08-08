import { PrismaClient, GoalCategory, GoalPriority } from '@prisma/client';

const prisma = new PrismaClient();

async function main(): Promise<void> {
  const devUserId =
    process.env.DEV_USER_ID ?? '00000000-0000-4000-8000-000000000001';
  const otherUserId = '00000000-0000-4000-8000-000000000002';

  const emma = await prisma.user.upsert({
    where: { id: devUserId },
    update: {
      email: process.env.DEV_USER_EMAIL ?? 'emma@example.com',
      displayName: process.env.DEV_USER_DISPLAY_NAME ?? 'Emma Chen',
      timezone: process.env.DEV_USER_TIMEZONE ?? 'Asia/Karachi',
      currencyCode: process.env.DEV_USER_CURRENCY ?? 'PKR',
    },
    create: {
      id: devUserId,
      email: process.env.DEV_USER_EMAIL ?? 'emma@example.com',
      displayName: process.env.DEV_USER_DISPLAY_NAME ?? 'Emma Chen',
      timezone: process.env.DEV_USER_TIMEZONE ?? 'Asia/Karachi',
      currencyCode: process.env.DEV_USER_CURRENCY ?? 'PKR',
    },
  });

  await prisma.user.upsert({
    where: { id: otherUserId },
    update: {
      email: 'other@example.com',
      displayName: 'Other User',
    },
    create: {
      id: otherUserId,
      email: 'other@example.com',
      displayName: 'Other User',
      timezone: 'UTC',
      currencyCode: 'USD',
    },
  });

  const existing = await prisma.goal.count({ where: { userId: emma.id } });
  if (existing === 0) {
    const deadline = new Date();
    deadline.setUTCMonth(deadline.getUTCMonth() + 6);

    const goal = await prisma.goal.create({
      data: {
        userId: emma.id,
        name: 'Emergency fund',
        description: 'Six months of expenses',
        category: GoalCategory.financial,
        priority: GoalPriority.high,
        targetAmountMinor: 50_000_000,
        currentAmountMinor: 10_000_000,
        currencyCode: 'PKR',
        deadline,
        progressPercent: 20,
        notes: 'Seed goal',
        milestones: {
          create: [
            {
              title: 'First 100k',
              order: 0,
              targetDate: new Date(
                Date.UTC(
                  deadline.getUTCFullYear(),
                  deadline.getUTCMonth() - 4,
                  1,
                ),
              ),
            },
            {
              title: 'Halfway',
              order: 1,
              targetDate: new Date(
                Date.UTC(
                  deadline.getUTCFullYear(),
                  deadline.getUTCMonth() - 2,
                  1,
                ),
              ),
            },
          ],
        },
      },
    });

    // eslint-disable-next-line no-console
    console.log(`Seeded goal ${goal.id} for ${emma.displayName}`);
  } else {
    // eslint-disable-next-line no-console
    console.log(`User ${emma.displayName} already has ${existing} goal(s)`);
  }
}

main()
  .catch((e) => {
    // eslint-disable-next-line no-console
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
