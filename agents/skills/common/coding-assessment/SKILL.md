---
name: coding-assessment
description: >
  Structured workflow for timed coding assessments (up to 90 min). Covers triage,
  diagnosis, fix-and-commit loop, and time-pressure documentation. Trigger when
  user says "coding assessment", "take assessment", "diagnose codebase", or types
  /coding-assessment.
---

# Coding Assessment Skill

90-minute timed workflow. Phases are time-boxed. Root cause before fix, always.

---

## Phase 1 — Triage (First 10–20 min)

**Goal:** Full picture before touching anything.

### 1.1 Read Everything First

Work through files in this order:
1. `README` / docs — understand intended behavior
2. Entry points (`main`, `index`, `app`, server bootstrap)
3. Auth / session / middleware
4. Data access layer (queries, ORM models, migrations)
5. Business logic
6. Tests (if any) — note what's covered and what's not

### 1.2 Map the Architecture

Sketch (mentally or in notes) the data flow:

```
request → middleware → handler → service → data layer → response
```

Note: where auth happens, where user input flows, where secrets live.

### 1.3 Build a Suspicion Log

Create a scratch file `NOTES.md` at the repo root. For each suspect, log:

```
[SEVERITY] LOCATION: one-line observation
```

Severity levels: `CRITICAL` / `HIGH` / `MEDIUM` / `LOW`

Common things to flag:
- Auth: missing checks, weak token validation, role bypass
- Injection: raw string interpolation in queries, shell calls, eval
- Data exposure: secrets in source, over-fetching in responses
- Logic: off-by-one, wrong comparison operator, missing null check
- Concurrency: shared mutable state, missing locks
- Config: hardcoded credentials, insecure defaults

**Do NOT fix anything in Phase 1. Flag and move on.**

### 1.4 Prioritize

After reading everything, rank your suspicion log by:
1. Severity (CRITICAL first)
2. Confidence (high confidence over speculative)
3. Blast radius (auth bugs outrank style issues)

---

## Phase 2 — Fix Loop (Min 20 → ~70)

**One issue at a time. Root cause first, fix second.**

### For each fix:

**Step A — State the root cause**

Write it out before touching code. Format:

```
ROOT CAUSE: [What is broken and why it is a problem]
IMPACT: [What an attacker/user can do because of this]
FIX PLAN: [Minimal change that addresses the root, not the symptom]
```

Example:
```
ROOT CAUSE: SQL query on line 42 interpolates user input directly into string.
            No parameterization. Classic injection vector.
IMPACT: Attacker can dump tables, bypass auth, or delete data.
FIX PLAN: Replace string interpolation with parameterized query / prepared statement.
```

**Step B — Apply minimal fix**

- Fix the root cause, not adjacent code
- Don't clean up unrelated style issues in the same edit
- Don't refactor while fixing a bug

**Step C — Run tests**

```bash
# run whatever the project's test command is
npm test / pytest / go test ./... / etc.
```

Note pass/fail. If tests were absent, note that.

**Step D — Commit**

One fix = one commit. Message format:

```
fix: [what was broken] — [one-line why]

Root cause: [sentence]
Impact: [sentence]
```

Example:
```
fix: parameterize user query on /search endpoint — SQL injection risk

Root cause: user input was interpolated directly into query string.
Impact: unauthenticated attacker could read or delete arbitrary rows.
```

**Repeat Step A–D for each issue.**

---

## Phase 3 — Time-Pressure Pivot (if < 15 min left)

**Stop fixing. Start documenting unfixed issues.**

For each remaining item in the suspicion log, write a section in `NOTES.md`:

```markdown
## [SEVERITY] Issue: [short title]

**Location:** file:line

**Root Cause:**
[What is broken and why]

**Impact:**
[What can go wrong because of this]

**Suggested Fix:**
[What a correct fix would look like — no need to implement]

**Confidence:** High / Medium / Low
```

This writeup counts. Assessors want to see that you found it and understood it, even if time ran out.

---

## What Makes You Stand Out

These behaviors separate strong candidates:

| Average | Strong |
|---|---|
| "I fixed the SQL query" | "User input was interpolated raw — attacker can dump the DB. Fixed with parameterized query." |
| Fix first, explain after | Root cause written before touching code |
| Batch fixes, one commit | One fix, one commit, tests between each |
| Vague commit messages | Commit message includes root cause and impact |
| Panic when time runs out | Pivots to documentation, explains everything found |
| Cleans up everything in sight | Fixes the problem, not the neighborhood |

---

## Time Budget Reference

| Phase | Time |
|---|---|
| Triage + suspicion log | 10–20 min |
| Fix loop | 20–70 min |
| Buffer / time-pressure docs | 70–90 min |

When Phase 2 hits the 70-min mark, finish the current fix and pivot to documentation regardless.

---

## Quick Checklist for Common Vulnerability Classes

### Injection
- [ ] User input ever reaches a query/shell/eval without sanitization?
- [ ] ORM used? Or raw string concat?

### Auth / AuthZ
- [ ] Every protected route checks auth?
- [ ] Tokens validated (expiry, signature, not just presence)?
- [ ] Role/permission checks on privileged operations?
- [ ] Password hashed? Which algorithm? (bcrypt/argon2 good; MD5/SHA1 bad)

### Data Exposure
- [ ] API responses return only needed fields?
- [ ] Secrets in source code or `.env` committed?
- [ ] Error messages leak stack traces or internal paths?

### Logic
- [ ] Off-by-one in loops or range checks?
- [ ] Null/undefined handled at boundaries?
- [ ] Comparisons use `===` not `==` (JS) or `is` not `==` (Python identity traps)?

### Crypto / Sessions
- [ ] Session tokens cryptographically random?
- [ ] Sensitive data encrypted at rest?
- [ ] HTTPS enforced?

---

## Notes File Template

Create `NOTES.md` at repo root at the start of Phase 1:

```markdown
# Assessment Notes
Date: [date]
Repo: [name]

## Architecture Summary
[2-3 sentences on what the app does and data flow]

## Suspicion Log

| Severity | Location | Observation | Status |
|---|---|---|---|
| CRITICAL | auth/middleware.js:34 | No token expiry check | FIXED |
| HIGH | db/queries.js:89 | Raw string interpolation | OPEN |

## Fixed Issues
[populated as you fix]

## Unfixed Issues
[populated in Phase 3 if time runs out]
```
