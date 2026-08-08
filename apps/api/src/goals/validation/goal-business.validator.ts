import { BadRequestException } from '@nestjs/common';
import { GoalCategory, GoalStatus, Prisma } from '@prisma/client';
import { ErrorCodes } from '../../common/errors/error-codes';
import {
  moneyMinorToApiString,
  parseOptionalMoneyMinorString,
} from '../money/money-minor';

export type GoalMoneyInput = {
  targetAmountMinor?: string | null;
  currentAmountMinor?: string | null;
  currencyCode?: string | null;
};

export type ParsedGoalMoney = {
  /** undefined = leave unchanged (update); null = clear */
  targetAmountMinor?: Prisma.Decimal | null;
  currentAmountMinor?: Prisma.Decimal | null;
  currencyCode?: string | null;
};

export type ExistingMoney = {
  targetAmountMinor?: Prisma.Decimal | null;
  currentAmountMinor?: Prisma.Decimal | null;
  currencyCode?: string | null;
};

/**
 * Server-side Goal business rules. Throws BadRequestException with domain codes.
 */
export class GoalBusinessValidator {
  static assertName(
    name: string | undefined,
    required: boolean,
  ): string | undefined {
    if (name === undefined) {
      if (required) {
        throw new BadRequestException({
          code: ErrorCodes.GOAL_NAME_REQUIRED,
          message: 'Goal name is required',
          details: {},
        });
      }
      return undefined;
    }
    const trimmed = name.trim();
    if (!trimmed) {
      throw new BadRequestException({
        code: ErrorCodes.GOAL_NAME_REQUIRED,
        message: 'Goal name must not be empty or whitespace',
        details: {},
      });
    }
    if (trimmed.length > 200) {
      throw new BadRequestException({
        code: ErrorCodes.VALIDATION_ERROR,
        message: 'Goal name must be at most 200 characters',
        details: {},
      });
    }
    return trimmed;
  }

  static assertCategory(
    category: string,
    customCategoryName?: string | null,
  ): { customCategoryName: string | null } {
    if (category === GoalCategory.custom) {
      const custom = customCategoryName?.trim() ?? '';
      if (!custom) {
        throw new BadRequestException({
          code: ErrorCodes.GOAL_CUSTOM_CATEGORY_REQUIRED,
          message: 'customCategoryName is required when category is custom',
          details: {},
        });
      }
      return { customCategoryName: custom };
    }
    if (
      customCategoryName != null &&
      String(customCategoryName).trim() !== ''
    ) {
      throw new BadRequestException({
        code: ErrorCodes.VALIDATION_ERROR,
        message: 'customCategoryName is only allowed when category is custom',
        details: {},
      });
    }
    return { customCategoryName: null };
  }

  static assertDeadlineNotPastForActiveCreate(
    deadline: Date,
    status: string,
  ): void {
    if (status !== GoalStatus.active && status !== 'active') {
      return;
    }
    const today = dateOnlyUtc(new Date());
    const due = dateOnlyUtc(deadline);
    if (due.getTime() < today.getTime()) {
      throw new BadRequestException({
        code: ErrorCodes.GOAL_DEADLINE_IN_PAST,
        message: 'An active goal cannot be created with a past deadline',
        details: { deadline: deadline.toISOString() },
      });
    }
  }

  static assertCurrencyCode(code: string | null | undefined): string | null {
    if (code === undefined || code === null || code === '') {
      return null;
    }
    const trimmed = code.trim();
    // Require already-uppercase ISO-like codes — do not silently accept "pkr".
    if (!/^[A-Z]{3}$/.test(trimmed)) {
      throw new BadRequestException({
        code: ErrorCodes.GOAL_CURRENCY_REQUIRED,
        message: 'currencyCode must be exactly three uppercase ASCII letters',
        details: { currencyCode: code },
      });
    }
    return trimmed;
  }

  /**
   * Parse money fields from API strings and enforce:
   * - target > 0 when supplied
   * - current >= 0
   * - current <= target when both present
   * - currency required when any amount is supplied
   */
  static parseAndAssertMoney(
    input: GoalMoneyInput,
    existing?: ExistingMoney,
  ): ParsedGoalMoney {
    const result: ParsedGoalMoney = {};

    if (Object.prototype.hasOwnProperty.call(input, 'targetAmountMinor')) {
      if (input.targetAmountMinor === null) {
        result.targetAmountMinor = null;
      } else if (input.targetAmountMinor !== undefined) {
        result.targetAmountMinor = parseOptionalMoneyMinorString(
          input.targetAmountMinor,
          {
            field: 'targetAmountMinor',
            requirePositive: true,
            code: ErrorCodes.GOAL_TARGET_AMOUNT_INVALID,
          },
        )!;
      }
    }

    if (Object.prototype.hasOwnProperty.call(input, 'currentAmountMinor')) {
      if (input.currentAmountMinor === null) {
        result.currentAmountMinor = null;
      } else if (input.currentAmountMinor !== undefined) {
        result.currentAmountMinor = parseOptionalMoneyMinorString(
          input.currentAmountMinor,
          {
            field: 'currentAmountMinor',
            requirePositive: false,
            code: ErrorCodes.GOAL_TARGET_AMOUNT_INVALID,
          },
        )!;
      }
    }

    if (Object.prototype.hasOwnProperty.call(input, 'currencyCode')) {
      if (input.currencyCode === undefined) {
        // Caller included the key with undefined — treat as "not provided".
      } else {
        result.currencyCode = this.assertCurrencyCode(input.currencyCode);
      }
    }

    const resolvedTarget =
      result.targetAmountMinor !== undefined
        ? result.targetAmountMinor
        : (existing?.targetAmountMinor ?? null);
    const resolvedCurrent =
      result.currentAmountMinor !== undefined
        ? result.currentAmountMinor
        : (existing?.currentAmountMinor ?? null);
    const resolvedCurrency =
      result.currencyCode !== undefined
        ? result.currencyCode
        : (existing?.currencyCode ?? null);

    const amountTouched =
      result.targetAmountMinor !== undefined ||
      result.currentAmountMinor !== undefined ||
      result.currencyCode !== undefined;

    if (amountTouched) {
      const hasAmount = resolvedTarget != null || resolvedCurrent != null;
      if (hasAmount && !resolvedCurrency) {
        throw new BadRequestException({
          code: ErrorCodes.GOAL_CURRENCY_REQUIRED,
          message:
            'currencyCode is required when a monetary amount is supplied',
          details: {},
        });
      }
    }

    if (resolvedTarget != null && resolvedTarget.lte(0)) {
      throw new BadRequestException({
        code: ErrorCodes.GOAL_TARGET_AMOUNT_INVALID,
        message: 'targetAmountMinor must be greater than zero when supplied',
        details: {},
      });
    }

    if (
      resolvedTarget != null &&
      resolvedCurrent != null &&
      resolvedCurrent.gt(resolvedTarget)
    ) {
      throw new BadRequestException({
        code: ErrorCodes.GOAL_CURRENT_AMOUNT_EXCEEDS_TARGET,
        message: 'currentAmountMinor may not exceed targetAmountMinor',
        details: {
          currentAmountMinor: moneyMinorToApiString(resolvedCurrent),
          targetAmountMinor: moneyMinorToApiString(resolvedTarget),
        },
      });
    }

    // When both amounts cleared on update, also clear currency.
    if (
      result.targetAmountMinor === null &&
      result.currentAmountMinor === null
    ) {
      result.currencyCode = null;
    }

    return result;
  }

  static assertProgressPercent(value: number | undefined): number | undefined {
    if (value === undefined) return undefined;
    if (value < 0 || value > 100 || Number.isNaN(value)) {
      throw new BadRequestException({
        code: ErrorCodes.VALIDATION_ERROR,
        message: 'progressPercent must be between 0 and 100',
        details: { progressPercent: value },
      });
    }
    return value;
  }
}

function dateOnlyUtc(value: Date): Date {
  return new Date(
    Date.UTC(value.getUTCFullYear(), value.getUTCMonth(), value.getUTCDate()),
  );
}
