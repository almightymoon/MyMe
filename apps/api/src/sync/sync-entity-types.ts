export const SYNC_ENTITY_TYPES = [
  'profile',
  'preference',
  'goal',
  'goalMilestone',
  'goalProgress',
  'financeCategory',
  'financeTransaction',
  'financeBudget',
  'financeMoneyPosition',
  'financeMoneyPositionPayment',
  'habit',
  'habitCheckIn',
  'habitScheduleRevision',
  'habitStatusPeriod',
  'wardrobeItem',
  'wardrobeOutfit',
  'wardrobeOutfitPlan',
  'wardrobeWearRecord',
  'wardrobeAsset',
  'memyCalendarEvent',
] as const;

export type SyncEntityType = (typeof SYNC_ENTITY_TYPES)[number];

export const REJECTED_ENTITY_TYPES = [
  'health',
  'healthSample',
  'heartRate',
  'sleep',
  'workout',
  'importedCalendarEvent',
  'deviceCalendar',
  'deviceCalendarLink',
  'preciseLocation',
] as const;

export const SYNC_OPERATIONS = ['create', 'update', 'delete'] as const;
export type SyncOperation = (typeof SYNC_OPERATIONS)[number];

export const UUID_RE =
  /^[0-9a-f]{8}-[0-9a-f]{4}-[1-8][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
export const MONEY_MINOR_RE = /^-?\d+$/;
export const CURRENCY_RE = /^[A-Z]{3}$/;
export const LOCAL_DATE_RE = /^\d{4}-\d{2}-\d{2}$/;
