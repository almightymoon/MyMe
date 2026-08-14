-- Convert Goal / GoalProgressEntry monetary minor-unit columns from INTEGER
-- to DECIMAL(30,0) so values such as PKR 150,000,000 (15_000_000_000 paisa)
-- are stored precisely without IEEE floating-point or 32-bit int overflow.
-- Existing integer values are preserved via CAST.

ALTER TABLE "Goal"
  ALTER COLUMN "targetAmountMinor" TYPE DECIMAL(30,0)
  USING ("targetAmountMinor"::numeric);

ALTER TABLE "Goal"
  ALTER COLUMN "currentAmountMinor" TYPE DECIMAL(30,0)
  USING ("currentAmountMinor"::numeric);

ALTER TABLE "GoalProgressEntry"
  ALTER COLUMN "previousAmountMinor" TYPE DECIMAL(30,0)
  USING ("previousAmountMinor"::numeric);

ALTER TABLE "GoalProgressEntry"
  ALTER COLUMN "newAmountMinor" TYPE DECIMAL(30,0)
  USING ("newAmountMinor"::numeric);
