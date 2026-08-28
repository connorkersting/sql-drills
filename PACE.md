# PACE.md

## Provenance

- **`CALENDAR.md` section 6 on Google Drive owns the target numbers.** Sections 6
  and 7 of that file are authoritative for the weekly scheduled counts, the phase
  boundaries, the floor/stretch, and the slack reserve.
- **This file is a derived mirror.** It restates those targets and pairs them with
  actuals computed from this repo. It is not a second source of truth. Where this
  file and `CALENDAR.md` disagree, `CALENDAR.md` is right and this file is stale.
- **Refresh date: 2026-08-25.** Targets below are a snapshot taken on that date.
- **Actuals sources, corrected 2026-08-25; counting rule amended 2026-08-26.**
  Solved is counted from `log.csv` as the rows whose `state` is `solved` or
  `shown`, never as a bare row count. Rows with `state` of `queued` (the next
  problem, written at the end of the prior session) or `attempted-not-run` (the
  environment timebox fired) are excluded: neither is a worked problem, and
  counting rows would have inflated the bar by one from the first queued row on.
  A `shown` row is worked and accepted with a re-derivation still owed; it counts,
  and it flips to `solved` when the re-derivation is done.
  Committed is counted by finding files in `problems/` with a non-comment body.
  These are two different measurements, and the earlier claim that actuals came
  from "`log.csv` and `problems/*.sql`" hid that: reading `problems/*.sql` only
  ever read a marker comment, never a query. `log.csv` has no column recording
  where a query ran, so it cannot tell a DuckDB solve from a LeetCode-editor
  solve. That column is a pending schema change.

## Definitions

Set by the 2026-08-25 ruling in `STATUS.md` Decisions. The former **Executed** and
**Stub** definitions are void; do not restore them.

- **Solved:** the problem was worked and the query accepted. This is the only
  figure counted toward the 100 floor and the 130 stretch. The ten problems solved
  in LeetCode's web editor count, because its hidden test cases are a stricter
  correctness check than the sample rows in a `-setup.sql` file.
- **Committed:** a query body saved in `problems/` after running in DuckDB.
  Through 2026-08-25 this is zero: no file in `problems/` has ever carried a query.
  This bar measures local execution, raw error reading, environment work against a
  zero infrastructure baseline, and the artifact. None of that happened.
- From **2026-08-26** the loop is solve in DuckDB, submit once on LeetCode as a
  confirming second oracle, save the file, log, commit. DuckDB is the bar; the
  submit is a check, never a retry loop. The save moves inside the solve, so
  committed and ran-in-DuckDB become the same event and the two bars converge.
  Superseded on the LeetCode clause only: the 2026-08-25 wording said LeetCode
  supplies the problem statement only, and the 2026-08-26 Command Center ruling
  made submit the second oracle.

## Phase 1 scope

- Phase 1 = WK01 (2026-08-17) through WK11 (2026-11-01). Weeks run Monday-Sunday.
- 116 scheduled problems + 7 timed sets. Floor 100, stretch 130.
- 16 problems of slack, reserved for the WK06-WK08 exam cluster. The draw-down
  against that reserve is owned by `STATUS.md` Open loops and is not mirrored here.
- Block 1 = WK01+WK02+WK03 = 32. Block 2 = WK04+WK05 = 36.
  Block 3 = WK07+WK08+WK09 = 26.

## Weekly targets and actuals

| Week | Dates | Scheduled | Cum. target | **Solved** | **Cum. solved** | **Committed** |
|---|---|---:|---:|---:|---:|---:|
| WK01 | 2026-08-17 .. 2026-08-23 | 8 | 8 | 7 | 7 | 0 |
| WK02 | 2026-08-24 .. 2026-08-30 | 18 | 26 | 4 | 11 | 1 |
| WK03 | 2026-08-31 .. 2026-09-06 | 6 | 32 | - | - | - |
| WK04 | 2026-09-07 .. 2026-09-13 | 18 | 50 | - | - | - |
| WK05 | 2026-09-14 .. 2026-09-20 | 18 | 68 | - | - | - |
| WK06 | 2026-09-21 .. 2026-09-27 | 8 | 76 | - | - | - |
| WK07 | 2026-09-28 .. 2026-10-04 | 8 | 84 | - | - | - |
| WK08 | 2026-10-05 .. 2026-10-11 | 6 | 90 | - | - | - |
| WK09 | 2026-10-12 .. 2026-10-18 | 12 | 102 | - | - | - |
| WK10 | 2026-10-19 .. 2026-10-25 | 8 | 110 | - | - | - |
| WK11 | 2026-10-26 .. 2026-11-01 | 6 | 116 | - | - | - |
| **Total** | | **116** | | **11** | | **1** |

Weeks after the refresh date show `-` rather than `0`; they are unstarted, not missed.

## Position as of 2026-08-27 (WK02 day 4, Thursday)

- **Solved: 11** of 22 scheduled phase-to-date. **Variance -11.**
- **Committed: 1** of 22.
- On-plan cumulative for today, per `CALENDAR.md`: **22** (WK01 8 scheduled, plus
  WK02 Mon 3, Tue 4, Wed 3, Thu 4; the per-day targets are in `CALENDAR.md` section 7).
- WK02 week-to-date: 4 solved of 18 scheduled, 1 committed. Tue Aug 25 and Wed Aug 26 at zero.

The on-plan baseline is built on WK01 **scheduled** 8, not WK01 actual 7, because
`CALENDAR.md` owns the target and a target is never restated to match what happened.
The -8 and -4 variances this file previously carried mixed a logged-basis baseline
with an executed-basis actual, and both are withdrawn.

## WK02 day targets

| Day | Date | Target | Solved | Committed |
|---|---|---:|---:|---:|
| Mon | 2026-08-24 | 3 | 3 | 0 |
| Tue | 2026-08-25 | 4 | 0 | 0 |
| Wed | 2026-08-26 | 3 | - | - |
| Thu | 2026-08-27 | 4 | - | - |
| Fri | 2026-08-28 | 4 | - | - |
| **Total** | | **18** | | |

---

A WK## target row is refreshed only when CALENDAR.md changes. It is never edited to
match a shortfall. A shortfall is a variance, not a new target.
