import { Prisma } from '@prisma/client';
import {
  ceilDivBigInt,
  moneyMinorToApiString,
  moneyMinorToBigInt,
  parseMoneyMinorString,
  progressPercentFromAmounts,
} from './money-minor';
import { BadRequestException } from '@nestjs/common';

describe('money-minor', () => {
  it('parses large PKR target string', () => {
    const d = parseMoneyMinorString('15000000000', {
      field: 'targetAmountMinor',
      requirePositive: true,
    });
    expect(d.toFixed(0)).toBe('15000000000');
    expect(moneyMinorToApiString(d)).toBe('15000000000');
  });

  it('rejects numeric JSON numbers', () => {
    expect(() =>
      parseMoneyMinorString(15000000000 as unknown as string, {
        field: 'targetAmountMinor',
      }),
    ).toThrow(BadRequestException);
  });

  it('rejects decimal point', () => {
    expect(() =>
      parseMoneyMinorString('100.5', { field: 'targetAmountMinor' }),
    ).toThrow(BadRequestException);
  });

  it('rejects negative', () => {
    expect(() =>
      parseMoneyMinorString('-1', { field: 'targetAmountMinor' }),
    ).toThrow(BadRequestException);
  });

  it('rejects zero when requirePositive', () => {
    expect(() =>
      parseMoneyMinorString('0', {
        field: 'targetAmountMinor',
        requirePositive: true,
      }),
    ).toThrow(BadRequestException);
  });

  it('computes progress with floor integer percent', () => {
    const percent = progressPercentFromAmounts(
      new Prisma.Decimal('2500'),
      new Prisma.Decimal('10000'),
    );
    expect(percent).toBe(25);
  });

  it('returns 100 when current reaches target', () => {
    expect(
      progressPercentFromAmounts(
        new Prisma.Decimal('10000'),
        new Prisma.Decimal('10000'),
      ),
    ).toBe(100);
  });

  it('returns 0 when current is zero', () => {
    expect(
      progressPercentFromAmounts(
        new Prisma.Decimal(0),
        new Prisma.Decimal('10000'),
      ),
    ).toBe(0);
  });

  it('floors uneven ratios', () => {
    expect(
      progressPercentFromAmounts(new Prisma.Decimal(1), new Prisma.Decimal(3)),
    ).toBe(33);
  });

  it('ceilDivBigInt rounds up', () => {
    expect(ceilDivBigInt(1000001n, 2n)).toBe(500001n);
  });

  it('moneyMinorToBigInt handles Decimal', () => {
    expect(moneyMinorToBigInt(new Prisma.Decimal('15000000000'))).toBe(
      15000000000n,
    );
  });
});
