import { BadRequestException } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { ErrorCodes } from '../../common/errors/error-codes';

/** Whole-number digit string, 1–30 digits (matches DECIMAL(30,0)). */
export const MONEY_MINOR_PATTERN = /^[0-9]{1,30}$/;

export type MoneyParseOptions = {
  field: string;
  /** When true, reject "0". */
  requirePositive?: boolean;
  /** Domain error code for structured responses. */
  code?: string;
};

/**
 * Validates and converts an API monetary minor-unit string to Prisma.Decimal.
 * Never uses Number / parseInt / unary-plus for stored money.
 */
export function parseMoneyMinorString(
  value: unknown,
  options: MoneyParseOptions,
): Prisma.Decimal {
  const {
    field,
    requirePositive = false,
    code = ErrorCodes.GOAL_TARGET_AMOUNT_INVALID,
  } = options;

  if (value === null || value === undefined) {
    throw new BadRequestException({
      code,
      message: `${field} is required`,
      details: { field },
    });
  }

  if (typeof value !== 'string') {
    throw new BadRequestException({
      code,
      message: `${field} must be a whole-number decimal string`,
      details: { field, receivedType: typeof value },
    });
  }

  if (!MONEY_MINOR_PATTERN.test(value)) {
    throw new BadRequestException({
      code,
      message: `${field} must be a whole-number decimal string (no sign, decimal point, commas, or whitespace)`,
      details: { field, value },
    });
  }

  // Strip leading zeros but keep a single zero.
  const normalized = value.replace(/^0+(?=\d)/, '');
  const decimal = new Prisma.Decimal(normalized);

  if (requirePositive && decimal.lte(0)) {
    throw new BadRequestException({
      code: ErrorCodes.GOAL_TARGET_AMOUNT_INVALID,
      message: `${field} must be greater than zero`,
      details: { field, value: normalized },
    });
  }

  return decimal;
}

/** Optional money field: undefined/null stays undefined; otherwise parses. */
export function parseOptionalMoneyMinorString(
  value: unknown,
  options: MoneyParseOptions,
): Prisma.Decimal | undefined {
  if (value === undefined || value === null) {
    return undefined;
  }
  return parseMoneyMinorString(value, options);
}

/** Serialize Prisma Decimal / string / bigint to API digit string. */
export function moneyMinorToApiString(
  value: Prisma.Decimal | string | number | bigint | null | undefined,
): string | null {
  if (value === null || value === undefined) {
    return null;
  }
  if (typeof value === 'string') {
    if (!MONEY_MINOR_PATTERN.test(value)) {
      // Defensive: never emit unsafe JSON numbers from corrupt storage.
      throw new Error(`Corrupt monetary value in storage: ${value}`);
    }
    return value.replace(/^0+(?=\d)/, '');
  }
  if (typeof value === 'bigint') {
    return value.toString();
  }
  if (typeof value === 'number') {
    if (!Number.isFinite(value) || !Number.isInteger(value) || value < 0) {
      throw new Error(`Corrupt monetary number in storage: ${value}`);
    }
    // Only used for legacy in-memory fixtures within safe integer range.
    return Math.trunc(value).toString();
  }
  // Prisma.Decimal
  const fixed = value.toFixed(0);
  if (fixed.includes('.') || fixed.includes('-') || fixed.includes('e')) {
    throw new Error(`Corrupt Decimal monetary value: ${fixed}`);
  }
  return fixed.replace(/^0+(?=\d)/, '') || '0';
}

/** Convert Decimal to bigint for precise integer arithmetic. */
export function moneyMinorToBigInt(
  value: Prisma.Decimal | string | null | undefined,
): bigint | null {
  if (value === null || value === undefined) {
    return null;
  }
  const asString =
    typeof value === 'string' ? value : moneyMinorToApiString(value);
  if (asString === null) return null;
  return BigInt(asString);
}

/** Ceiling division for non-negative bigints: ceil(n / d). */
export function ceilDivBigInt(numerator: bigint, denominator: bigint): bigint {
  if (denominator <= 0n) return numerator;
  if (numerator <= 0n) return 0n;
  const result = (numerator + denominator - 1n) / denominator;
  if (result < 1n) return 1n;
  return result > numerator ? numerator : result;
}

/**
 * Financial progress percent 0–100 from amounts.
 *
 * Rule (documented, server-authoritative):
 *   progressPercent = floor(currentAmountMinor × 100 ÷ targetAmountMinor)
 * then clamp to [0, 100].
 *
 * Uses BigInt only — never IEEE Number for the monetary ratio.
 * When current ≥ target → 100; when current ≤ 0 → 0.
 */
export function calculateFinancialProgressPercent(
  current: Prisma.Decimal,
  target: Prisma.Decimal,
): number {
  if (target.lte(0)) return 0;
  if (current.gte(target)) return 100;
  if (current.lte(0)) return 0;
  const currentBi = BigInt(moneyMinorToApiString(current)!);
  const targetBi = BigInt(moneyMinorToApiString(target)!);
  const percent = (currentBi * 100n) / targetBi; // floor division
  const asNumber = Number(percent);
  return Math.min(100, Math.max(0, asNumber));
}

/** @deprecated Prefer {@link calculateFinancialProgressPercent}. */
export const progressPercentFromAmounts = calculateFinancialProgressPercent;
