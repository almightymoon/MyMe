# Finance Screen Logic Matrix

Baseline: commit `461d453` + uncommitted weather/wardrobe work. Money owed: **Option A — simple ledger in production**.

| Route | Screen | Prod | Data | Provider | Repo | Load | Empty | Error | Retry | Actions | Mutation | Persist | Cross | Status | Sev |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| `/finance` | FinanceOverviewScreen | Yes | Local | finance* | LocalFinanceRepository | Y | Y | Y | Y | Period, add, history, budgets, reports | — | Y | Today/Plan | Complete* | — |
| `/finance/new` | AddTransactionScreen | Yes | Form | TransactionFormController | Local | Busy | Val | Y | Re | Save | Dup-guard | Y | Today/Plan | Complete | — |
| `/finance/history` | TransactionHistoryScreen | Yes | Local | financeTransactions | Local | Y | Y | Y | Y | Filter, open | — | Y | — | Complete | — |
| `/finance/tx/:id` | TransactionDetailScreen | Yes | Local | byId | Local | Y | NF | Y | Y | Edit, delete | Confirm | Y | Today/Plan | Complete | — |
| `/finance/tx/:id/edit` | EditTransactionScreen | Yes | Form | FormController | Local | Busy | Val | Y | Re | Save | Dup-guard | Y | Today/Plan | Complete | — |
| `/finance/budgets` | BudgetsOverviewScreen | Yes | Local | budgets* | Local v2 | Y | Y | Y | Y | Month nav, add | — | Y | Today | Complete | P0 |
| `/finance/budgets/new` | AddBudgetScreen | Yes | Form | BudgetForm | Local | Busy | Val | Y | Re | Save | Dup-guard | Y | Today | Complete | P0 |
| `/finance/budgets/:id` | BudgetDetailScreen | Yes | Local | budgetById | Local | Y | NF | Y | Y | Edit, delete | Confirm | Y | Today | Complete | P0 |
| `/finance/budgets/:id/edit` | EditBudgetScreen | Yes | Form | BudgetForm | Local | Busy | Val | Y | Re | Save | Dup-guard | Y | Today | Complete | P0 |
| `/finance/reports` | FinanceReportsScreen | Yes | Derived | periodReport | Local txs | Y | Y | Y | Y | Period | — | Derived | — | Complete | P0 |
| `/finance/categories` | FinanceCategoriesScreen | Yes | Local | categories | Local | Y | Y | Y | Y | CRUD custom | Guard | Y | Forms | Complete | P1 |
| `/finance/owed` | MoneyOwedOverviewScreen | Yes | Local | moneyPositions | Local v3 | Y | Y | Y | Y | Add, open | — | Y | Overview | Complete | P0 |
| `/finance/owed/new` | AddMoneyOwedScreen | Yes | Form | MoneyOwedForm | Local | Busy | Val | Y | Re | Save | Dup-guard | Y | Overview | Complete | P0 |
| `/finance/owed/:id` | MoneyOwedDetailScreen | Yes | Local | byId | Local | Y | NF | Y | Y | Pay, edit, delete | Confirm; payment ≤ remaining | Y | Overview | Complete | P0 |
| `/finance/owed/:id/edit` | EditMoneyOwedScreen | Yes | Form | MoneyOwedForm | Local | Busy | Val | Y | Re | Save | Amount ≥ paid | Y | Overview | Complete | P0 |

\*Overview gains Budgets/Reports navigation and live budget card as part of this milestone.

## Loans decision

**Option A:** Simple money-owed ledger in production. No interest, no fake balances, no bank products.
