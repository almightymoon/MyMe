-- AlterTable
CREATE UNIQUE INDEX "RefreshSession_tokenHash_key" ON "RefreshSession"("tokenHash");
DROP INDEX IF EXISTS "RefreshSession_tokenHash_idx";

-- CreateEnum
CREATE TYPE "AssetKind" AS ENUM ('wardrobeOriginal', 'wardrobeThumbnail');

-- CreateEnum
CREATE TYPE "AssetUploadStatus" AS ENUM ('pending', 'uploaded', 'failed', 'deletionPending');

-- CreateTable
CREATE TABLE "SyncRecord" (
    "id" UUID NOT NULL,
    "userId" UUID NOT NULL,
    "entityType" TEXT NOT NULL,
    "entityId" TEXT NOT NULL,
    "serverVersion" INTEGER NOT NULL,
    "payload" JSONB NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "deletedAt" TIMESTAMP(3),
    "lastMutationId" TEXT NOT NULL,
    "lastDeviceId" UUID NOT NULL,

    CONSTRAINT "SyncRecord_pkey" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX "SyncRecord_userId_entityType_entityId_key" ON "SyncRecord"("userId", "entityType", "entityId");
CREATE INDEX "SyncRecord_userId_updatedAt_idx" ON "SyncRecord"("userId", "updatedAt");

ALTER TABLE "SyncRecord" ADD CONSTRAINT "SyncRecord_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- CreateTable
CREATE TABLE "SyncMutationReceipt" (
    "id" UUID NOT NULL,
    "userId" UUID NOT NULL,
    "mutationId" TEXT NOT NULL,
    "acceptedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "result" TEXT NOT NULL,
    "serverVersion" INTEGER,

    CONSTRAINT "SyncMutationReceipt_pkey" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX "SyncMutationReceipt_userId_mutationId_key" ON "SyncMutationReceipt"("userId", "mutationId");

ALTER TABLE "SyncMutationReceipt" ADD CONSTRAINT "SyncMutationReceipt_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- CreateTable
CREATE TABLE "SyncChangeLog" (
    "sequence" BIGSERIAL NOT NULL,
    "userId" UUID NOT NULL,
    "entityType" TEXT NOT NULL,
    "entityId" TEXT NOT NULL,
    "operation" TEXT NOT NULL,
    "serverVersion" INTEGER NOT NULL,
    "changedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "payload" JSONB,

    CONSTRAINT "SyncChangeLog_pkey" PRIMARY KEY ("sequence")
);

CREATE INDEX "SyncChangeLog_userId_sequence_idx" ON "SyncChangeLog"("userId", "sequence");
CREATE INDEX "SyncChangeLog_userId_entityType_entityId_idx" ON "SyncChangeLog"("userId", "entityType", "entityId");

ALTER TABLE "SyncChangeLog" ADD CONSTRAINT "SyncChangeLog_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- CreateTable
CREATE TABLE "Asset" (
    "id" UUID NOT NULL,
    "userId" UUID NOT NULL,
    "kind" "AssetKind" NOT NULL,
    "objectKey" TEXT NOT NULL,
    "mimeType" TEXT NOT NULL,
    "byteSize" INTEGER NOT NULL,
    "checksum" TEXT NOT NULL,
    "width" INTEGER,
    "height" INTEGER,
    "version" INTEGER NOT NULL DEFAULT 1,
    "uploadStatus" "AssetUploadStatus" NOT NULL DEFAULT 'pending',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "deletedAt" TIMESTAMP(3),

    CONSTRAINT "Asset_pkey" PRIMARY KEY ("id")
);

CREATE INDEX "Asset_userId_idx" ON "Asset"("userId");
CREATE UNIQUE INDEX "Asset_objectKey_key" ON "Asset"("objectKey");

ALTER TABLE "Asset" ADD CONSTRAINT "Asset_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;
