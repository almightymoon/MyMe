enum SyncEntityType {
  profile,
  preference,
  goal,
  goalMilestone,
  goalProgress,
  financeCategory,
  financeTransaction,
  financeBudget,
  financeMoneyPosition,
  financeMoneyPositionPayment,
  habit,
  habitCheckIn,
  habitScheduleRevision,
  habitStatusPeriod,
  wardrobeItem,
  wardrobeOutfit,
  wardrobeOutfitPlan,
  wardrobeWearRecord,
  wardrobeAsset,
  memyCalendarEvent,
}

enum SyncOperationType { create, update, delete }

enum SyncMutationState {
  pending,
  uploading,
  accepted,
  conflict,
  retryableFailure,
  permanentlyFailed,
  requiresAuthentication,
}

enum SyncStatusKind {
  synced,
  syncing,
  offline,
  pendingChanges,
  signInRequired,
  error,
  conflict,
}

class SyncMutation {
  const SyncMutation({
    required this.mutationId,
    required this.accountId,
    required this.deviceId,
    required this.entityType,
    required this.entityId,
    required this.operation,
    required this.localVersion,
    required this.clientUpdatedAt,
    required this.createdAt,
    required this.attemptCount,
    required this.state,
    this.baseServerVersion,
    this.payload,
    this.nextAttemptAt,
  });

  final String mutationId;
  final String accountId;
  final String deviceId;
  final SyncEntityType entityType;
  final String entityId;
  final SyncOperationType operation;
  final int? baseServerVersion;
  final int localVersion;
  final DateTime clientUpdatedAt;
  final Map<String, Object?>? payload;
  final DateTime createdAt;
  final int attemptCount;
  final DateTime? nextAttemptAt;
  final SyncMutationState state;
}

class SyncConflict {
  const SyncConflict({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.detectedAt,
    required this.status,
  });

  final String id;
  final SyncEntityType entityType;
  final String entityId;
  final DateTime detectedAt;
  final String status;
}
