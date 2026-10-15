# Data Dictionary

**File:** `NUPRC_2025_Oil_Production_Long.csv`
**Source:** NUPRC, "Crude Oil and Condensate Production - 2025"
**Coverage:** January to December 2025
**Rows:** 417 (one row per month, terminal stream and liquid type)
**Terminal streams:** 29

| Column | Type | Meaning | Example / allowed values |
|---|---|---|---|
| `production_month` | Date | The month the figure belongs to (first day of the month) | 2025-01-01 |
| `terminal_stream` | Text | The terminal or stream that produced the oil | FORCADOS, BONNY, QUA IBOE |
| `liquid_type` | Text | Type of liquid | Crude Oil (320 rows), Condensate (97 rows) |
| `production_barrels` | Whole number | Reported production for that month, in barrels. Empty means the source did not report a value; it does not mean zero | 4688793 |
| `unit` | Text | Unit of measurement | barrels |
| `source` | Text | Where the figure came from | NUPRC Crude Oil and Condensate Production - 2025 |
| `data_status` | Text | How reliable or complete the figure is | reported, not_reported, reconciled_from_monthly_total |

## Notes

- **Missing values** are left empty on purpose. They are not replaced with zero.
- **Blend Total rows** from the original report are not included, to avoid counting the same oil twice.
- **Reconciled values:** some January and September figures were checked against monthly totals. The December Forcados crude oil figure (8,509,954 barrels) is marked `reconciled_from_monthly_total`.
- **Index column:** if your CSV has an extra first column of row numbers, it is not part of the data and can be ignored.
- **Unique key:** each combination of `production_month`, `terminal_stream` and `liquid_type` appears once.
