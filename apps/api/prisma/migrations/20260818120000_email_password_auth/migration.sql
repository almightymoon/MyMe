-- AlterEnum
ALTER TYPE "AuthProvider" ADD VALUE 'email';

-- AlterTable
ALTER TABLE "AuthIdentity" ADD COLUMN "passwordHash" TEXT;
