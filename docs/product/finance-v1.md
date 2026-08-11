# Finance v1

Local-first cash tracking. No banks, investments, AI advice, or currency conversion.

## Included

- Income and expense transactions (`MoneyMinor`, base currency)
- Built-in and custom categories (archive/restore; built-ins are not deleted)
- Monthly overall and per-category budgets (integer minor units and basis-point thresholds)
- Period reports derived from transactions and budgets (not stored as source of truth)
- Money owed ledger (I owe / owed to me, optional due date, payments that cannot exceed remaining)
- Today and Plan summaries from live ledger data
- Export (minor-unit strings) and local deletion (no reseed)

## Money owed / loans

Simple on-device ledger only: original amount, remaining, payments, open / overdue / settled. No interest, amortization, or fake loan balances. Bank products and lending marketplaces stay out of scope.

## Base currency

v1 uses one base currency from the user preference. Existing rows keep their stored currency code. Changing base currency does not silently relabel historical amounts.

## Out of scope

Bank sync, open banking, investments, crypto, subscriptions discovery, OCR, tax, multi-currency aggregation, AI advice, shared family finance, Finance APIs.
