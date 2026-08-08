export const ErrorCodes = {
  VALIDATION_ERROR: 'GOAL_VALIDATION_ERROR',
  NOT_FOUND: 'RESOURCE_NOT_FOUND',
  FORBIDDEN: 'OWNERSHIP_FORBIDDEN',
  UNAUTHORIZED: 'UNAUTHORIZED',
  CONFLICT: 'CONFLICT',
  INTERNAL: 'INTERNAL_ERROR',
} as const;

export type ErrorCode = (typeof ErrorCodes)[keyof typeof ErrorCodes];
