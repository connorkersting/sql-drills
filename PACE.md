# PACE.md

## Provenance

- **`CALENDAR.md` section 6 on Google Drive owns the target numbers.** Sections 6
  and 7 of that file are authoritative for the weekly scheduled counts, the phase
  boundaries, the floor/stretch, and the slack reserve.
- **This file is a derived mirror.** It restates those targets and pairs them with
  actuals computed from `log.csv` in this repo. It is not a second source of truth.
  Where this file and `CALENDAR.md` disagree, `CALENDAR.md` is right and this file
  is stale.
- **Refresh date: 2026-08-25.** Targets below are a snapshot taken on that date.
- Actuals are computed from `log.csv` and `problems/*.sql` in this repo.

## Definitions

- **Logged** — a row exists in `log.csv`.
- **Executed** — a row exists in `log.csv` *and* a real solution file exists in
  `problems/`. This is the only figure counted toward a target.
- **Stub** — a logged row whose `problems/` file is a `NOT RECOVERED` placeholder
  carrying no SQL. Stubs are excluded from every executed and cumulative total in
  this file. Re-solving one unaided converts it to executed.

## Phase 1 scope

- Phase 1 = WK01 (2026-08-17) through WK11 (2026-11-01). Weeks run Monday-Sunday.
- 116 scheduled problems + 7 timed sets. Floor 100, stretch 130.
- 16 problems of slack, reserved for the WK06-WK08 exam cluster.
- Block 1 = WK01+WK02+WK03 = 32. Block 2 = WK04+WK05 = 36.
  Block 3 = WK07+WK08+WK09 = 26.

## Weekly targets and actuals

| Week | Dates | Scheduled | Cum. target | Logged | Stubs | **Executed** | **Cum. executed** |
|---|---|---:|---:|---:|---:|---:|---:|
| WK01 | 2026-08-17 .. 2026-08-23 | 8 | 8 | 7 | 4 | 3 | 3 |
| WK02 | 2026-08-24 .. 2026-08-30 | 18 | 26 | 3 | 0 | 3 | 6 |
| WK03 | 2026-08-31 .. 2026-09-06 | 6 | 32 | — | — | — | — |
| WK04 | 2026-09-07 .. 2026-09-13 | 18 | 50 | — | — | — | — |
| WK05 | 2026-09-14 .. 2026-09-20 | 18 | 68 | — | — | — | — |
| WK06 | 2026-09-21 .. 2026-09-27 | 8 | 76 | — | — | — | — |
| WK07 | 2026-09-28 .. 2026-10-04 | 8 | 84 | — | — | — | — |
| WK08 | 2026-10-05 .. 2026-10-11 | 6 | 90 | — | — | — | — |
| WK09 | 2026-10-12 .. 2026-10-18 | 12 | 102 | — | — | — | — |
| WK10 | 2026-10-19 .. 2026-10-25 | 8 | 110 | — | — | — | — |
| WK11 | 2026-10-26 .. 2026-11-01 | 6 | 116 | — | — | — | — |
| **Total** | | **116** | | **10** | **4** | **6** | |

Weeks after the refresh date show `—` rather than `0`; they are unstarted, not missed.

## Position as of 2026-08-25 (WK02 day 2, Tuesday)

- Cumulative **executed**, excluding stubs: **6** of 116 phase-to-date.
- Cumulative **logged**, for reference only: 10 (4 of those are stubs and do not count).
- On-plan cumulative for today, per `CALENDAR.md`: **14**
  (WK01 actual 7, plus WK02 Mon 3, plus WK02 Tue 4).
- **Variance: -8** against plan.
- WK02 week-to-date: 3 executed of 18 scheduled.
- Slack: 15 of 16 remaining, reserved for the WK06-WK08 exam cluster.

### Note on the on-plan baseline

The on-plan figure of 14 is built on a WK01 contribution of 7, which is the *logged*
count. WK01 executed is 3, because 4 of those 7 rows have no recovered file. The 14
and the variance above therefore mix a logged-basis baseline with an executed-basis
actual. On a like-for-like executed basis the baseline would be 10 (3 + 3 + 4) and the
variance -4. `CALENDAR.md` owns which basis is correct; this file reports the 14
as given and does not silently substitute the other.

## WK02 day targets

| Day | Date | Target | Executed |
|---|---|---:|---:|
| Mon | 2026-08-24 | 3 | 3 |
| Tue | 2026-08-25 | 4 | 0 |
| Wed | 2026-08-26 | 3 | — |
| Thu | 2026-08-27 | 4 | — |
| Fri | 2026-08-28 | 4 | — |
| **Total** | | **18** | |

---

A WK## target row is refreshed only when CALENDAR.md changes. It is never edited to
match a shortfall. A shortfall is a variance, not a new target.
