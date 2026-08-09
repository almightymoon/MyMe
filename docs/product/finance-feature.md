# Finance feature

Local-first finance tracking for MeMy mobile (Flutter).

| Mode (`FINANCE_DATA_SOURCE`) | Implementation |
| --- | --- |
| `local` (default) | `LocalFinanceRepository` — SharedPreferences offline/demo |
| `fake` | `FakeFinanceRepository` — in-memory for demos/tests |

There is **no Finance backend API**, bank sync, loans, subscriptions, investments, or AI advice in this milestone. `FinanceRepository` is shaped so an `ApiFinanceRepository` can be added later.

UI never imports `FinanceSeed`. Screens use Riverpod providers only.

## User flow

1. Demo sign-in → Today (Finance card shows live balance / spent today / month totals)
2. Quick Add → **Add Transaction** (real form)
3. Save → success snackbar → Transaction detail
4. Finance Overview shows balance, period income/expense, spending breakdown
5. See All → Transaction History
6. Open → edit / delete with confirmation
7. Restart app → local mode restores SharedPreferences

## Domain model

- `FinanceTransaction` — type, `MoneyMinor` amount, currency, category, occurredAt, payment method, optional merchant/note
- `FinanceCategory` — name, type, iconKey (presentation maps colors)
- `FinanceSummary` — signed `currentBalanceMinor` (BigInt), non-negative period totals as `MoneyMinor`, category breakdown with basis points
- Enums: `TransactionType`, `PaymentMethod`, `FinancePeriod`

Domain entities **never** store formatted labels (`balanceLabel`, etc.).

### Money

Shared `MoneyMinor` (`BigInt` minor units / paisa) lives in `lib/core/domain/value_objects/money_minor.dart` (re-exported from the Goals path). Parsing/formatting via `MoneyFormat` (no `double` as source of truth).

Example: `"25,000"` → `2500000` minor units → display `PKR 25,000`.

Base currency for the MVP demo is **PKR**. Multi-currency conversion is future work; foreign-currency rows are ignored in summaries.

### Summary rules (`FinanceSummaryService`)

- **Balance** = all-time income − all-time expenses (may be negative)
- **Period income/expense** = sums inside selected period
- **Spent today** = expense sum for the local calendar day
- **Breakdown** = period expenses grouped by category (basis points)

Periods: This Month, Last Month, This Year, All Time.

## Repository selection

```bash
--dart-define=FINANCE_DATA_SOURCE=local
# or
--dart-define=FINANCE_DATA_SOURCE=fake
```

Override `financeDataSourceProvider` in tests.

## Local persistence

SharedPreferences keys:

- `memy_finance_initialized_v1`
- `memy_finance_v1` — `{ schemaVersion, baseCurrencyCode, categories, transactions }`

Money fields are digit strings. Timestamps are ISO-8601 UTC on disk, local on display.

Demo seed runs **only** when the initialized flag is absent. Deleting all transactions does **not** reseed.

## Deferred

Loans / lending UI is a **Planned feature** card (not fake live data). Bank sync, recurring txs, receipts, and API mode are out of scope.

## Tests

Unit: money parse/format, summary math, local CRUD/seed rules.  
Widget / integration: overview states, add/history/detail/edit/delete, Today updates, Quick Add → PKR 25,000 Food with duplicate-save protection + persistence.
