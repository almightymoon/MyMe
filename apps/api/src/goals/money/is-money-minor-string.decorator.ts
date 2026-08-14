import {
  registerDecorator,
  ValidationArguments,
  ValidationOptions,
} from 'class-validator';
import { MONEY_MINOR_PATTERN } from '../money/money-minor';

/**
 * Validates optional/required monetary minor-unit API strings.
 * Accepts string digit sequences only — rejects numbers and floats.
 */
export function IsMoneyMinorString(
  options?: { optional?: boolean; allowNull?: boolean } & ValidationOptions,
) {
  const {
    optional = true,
    allowNull = false,
    ...validationOptions
  } = options ?? {};

  return (object: object, propertyName: string) => {
    registerDecorator({
      name: 'isMoneyMinorString',
      target: object.constructor,
      propertyName,
      options: validationOptions,
      validator: {
        validate(value: unknown) {
          if (value === undefined) return optional;
          if (value === null) return allowNull;
          if (typeof value !== 'string') return false;
          return MONEY_MINOR_PATTERN.test(value);
        },
        defaultMessage(args: ValidationArguments) {
          return `${args.property} must be a whole-number decimal string (e.g. "15000000000")`;
        },
      },
    });
  };
}
