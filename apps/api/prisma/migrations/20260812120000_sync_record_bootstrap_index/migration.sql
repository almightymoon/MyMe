-- Bootstrap scans live records by (entityType, entityId) after filtering deletedAt.
CREATE INDEX "SyncRecord_userId_deletedAt_entityType_entityId_idx"
  ON "SyncRecord"("userId", "deletedAt", "entityType", "entityId");
