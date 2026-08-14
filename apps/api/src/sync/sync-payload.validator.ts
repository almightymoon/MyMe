import { BadRequestException } from '@nestjs/common';
import {
  CURRENCY_RE,
  LOCAL_DATE_RE,
  MONEY_MINOR_RE,
  REJECTED_ENTITY_TYPES,
  SYNC_ENTITY_TYPES,
  SYNC_OPERATIONS,
  SyncEntityType,
  SyncOperation,
  UUID_RE,
} from './sync-entity-types';

const MAX_STRING = 500;
const MAX_NOTES = 4000;

function asRecord(payload: unknown): Record<string, unknown> {
  if (!payload || typeof payload !== 'object' || Array.isArray(payload)) {
    throw new BadRequestException({
      code: 'SYNC_PAYLOAD_INVALID',
      message: 'Payload must be an object.',
    });
  }
  return payload as Record<string, unknown>;
}

function requireString(
  row: Record<string, unknown>,
  key: string,
  max = MAX_STRING,
): string {
  const value = row[key];
  if (typeof value !== 'string' || value.trim().length === 0) {
    throw new BadRequestException({
      code: 'SYNC_PAYLOAD_INVALID',
      message: `${key} is required.`,
    });
  }
  if (value.length > max) {
    throw new BadRequestException({
      code: 'SYNC_PAYLOAD_INVALID',
      message: `${key} is too long.`,
    });
  }
  return value;
}

function optionalString(
  row: Record<string, unknown>,
  key: string,
  max = MAX_STRING,
): string | undefined {
  const value = row[key];
  if (value == null) return undefined;
  if (typeof value !== 'string') {
    throw new BadRequestException({
      code: 'SYNC_PAYLOAD_INVALID',
      message: `${key} must be a string.`,
    });
  }
  if (value.length > max) {
    throw new BadRequestException({
      code: 'SYNC_PAYLOAD_INVALID',
      message: `${key} is too long.`,
    });
  }
  return value;
}

function rejectLocalPaths(row: Record<string, unknown>) {
  for (const [key, value] of Object.entries(row)) {
    if (typeof value !== 'string') continue;
    if (
      key.toLowerCase().includes('path') ||
      value.startsWith('/') ||
      value.includes('\\') ||
      value.startsWith('file:')
    ) {
      if (
        key === 'backendAssetId' ||
        key === 'localAssetState' ||
        UUID_RE.test(value)
      ) {
        continue;
      }
      throw new BadRequestException({
        code: 'SYNC_LOCAL_PATH_REJECTED',
        message: 'Local file paths are not accepted.',
      });
    }
  }
}

export function assertEntityType(value: string): SyncEntityType {
  if ((REJECTED_ENTITY_TYPES as readonly string[]).includes(value)) {
    throw new BadRequestException({
      code: 'SYNC_ENTITY_FORBIDDEN',
      message: 'This data stays on the device.',
    });
  }
  if (!(SYNC_ENTITY_TYPES as readonly string[]).includes(value)) {
    throw new BadRequestException({
      code: 'SYNC_ENTITY_UNKNOWN',
      message: 'Unknown entity type.',
    });
  }
  return value as SyncEntityType;
}

export function assertOperation(value: string): SyncOperation {
  if (!(SYNC_OPERATIONS as readonly string[]).includes(value)) {
    throw new BadRequestException({
      code: 'SYNC_OPERATION_INVALID',
      message: 'Unknown operation.',
    });
  }
  return value as SyncOperation;
}

export function assertEntityId(entityId: string) {
  if (!UUID_RE.test(entityId)) {
    throw new BadRequestException({
      code: 'SYNC_ENTITY_ID_INVALID',
      message: 'Entity IDs must be client-generated UUIDs.',
    });
  }
}

export function validatePayload(
  entityType: SyncEntityType,
  operation: SyncOperation,
  payload: unknown,
): Record<string, unknown> | null {
  if (operation === 'delete') {
    return payload == null ? null : asRecord(payload);
  }
  const row = asRecord(payload);
  rejectLocalPaths(row);

  switch (entityType) {
    case 'profile':
      optionalString(row, 'displayName', 80);
      optionalString(row, 'avatarKey', 64);
      return row;
    case 'preference': {
      const currency = optionalString(row, 'currencyCode', 3);
      if (currency && !CURRENCY_RE.test(currency)) {
        throw new BadRequestException({
          code: 'SYNC_CURRENCY_INVALID',
          message: 'Currency must be three uppercase letters.',
        });
      }
      optionalString(row, 'units', 16);
      optionalString(row, 'weekStart', 16);
      optionalString(row, 'timezone', 64);
      return row;
    }
    case 'goal':
      requireString(row, 'name', 120);
      optionalString(row, 'notes', MAX_NOTES);
      if (row.targetAmountMinor != null) {
        if (
          typeof row.targetAmountMinor !== 'string' ||
          !MONEY_MINOR_RE.test(row.targetAmountMinor)
        ) {
          throw new BadRequestException({
            code: 'SYNC_MONEY_INVALID',
            message: 'Amounts must be decimal minor-unit strings.',
          });
        }
      }
      if (
        row.currencyCode != null &&
        (typeof row.currencyCode !== 'string' ||
          !CURRENCY_RE.test(row.currencyCode))
      ) {
        throw new BadRequestException({
          code: 'SYNC_CURRENCY_INVALID',
          message: 'Currency must be three uppercase letters.',
        });
      }
      return row;
    case 'financeTransaction':
    case 'financeBudget':
    case 'financeMoneyPosition':
    case 'financeMoneyPositionPayment': {
      if (row.amountMinor != null) {
        if (
          typeof row.amountMinor !== 'string' ||
          !MONEY_MINOR_RE.test(row.amountMinor)
        ) {
          throw new BadRequestException({
            code: 'SYNC_MONEY_INVALID',
            message: 'Amounts must be decimal minor-unit strings.',
          });
        }
      }
      if (
        row.currencyCode != null &&
        (typeof row.currencyCode !== 'string' ||
          !CURRENCY_RE.test(row.currencyCode))
      ) {
        throw new BadRequestException({
          code: 'SYNC_CURRENCY_INVALID',
          message: 'Currency must be three uppercase letters.',
        });
      }
      return row;
    }
    case 'habitCheckIn': {
      const localDate = requireString(row, 'localDate', 10);
      if (!LOCAL_DATE_RE.test(localDate)) {
        throw new BadRequestException({
          code: 'SYNC_DATE_INVALID',
          message: 'Habit dates must be YYYY-MM-DD.',
        });
      }
      return row;
    }
    case 'goalMilestone':
    case 'goalProgress':
      requireString(row, 'goalId', 64);
      return row;
    case 'financeCategory':
      requireString(row, 'name', 80);
      return row;
    case 'habit':
      requireString(row, 'name', 120);
      return row;
    case 'habitScheduleRevision':
    case 'habitStatusPeriod':
      requireString(row, 'habitId', 64);
      return row;
    case 'wardrobeItem':
    case 'wardrobeOutfit':
    case 'wardrobeOutfitPlan':
    case 'wardrobeWearRecord':
    case 'wardrobeAsset':
      optionalString(row, 'backendAssetId', 64);
      if (row.localImagePath || row.absolutePath || row.exif) {
        throw new BadRequestException({
          code: 'SYNC_LOCAL_PATH_REJECTED',
          message: 'Local image paths and EXIF are not accepted.',
        });
      }
      return row;
    case 'memyCalendarEvent':
      requireString(row, 'title', 200);
      if (
        row.externalEventId ||
        row.deviceCalendarId ||
        row.imported === true
      ) {
        throw new BadRequestException({
          code: 'SYNC_CALENDAR_DEVICE_LOCAL',
          message: 'Imported device calendar data stays on the device.',
        });
      }
      return row;
    default:
      throw new BadRequestException({
        code: 'SYNC_ENTITY_UNKNOWN',
        message: 'Unknown entity type.',
      });
  }
}
