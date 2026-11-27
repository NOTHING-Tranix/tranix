---
description: Plan the next milestone from ROADMAP.md, then build it task by task after approval
---

1. Read `CLAUDE.md`, `ROADMAP.md`, the latest `docs/progress-log.md` entry, `backend/TODO.md` and `frontend/TODO.md`.
2. Pick the milestone in `$ARGUMENTS` (e.g. `M4`), else the first milestone that is `[~]` or `[ ]`. Mark it `[~]` in `ROADMAP.md`.
3. Read the relevant sections of `docs/product-spec.md`, `docs/api-contract.md`, `docs/decisions.md`, `docs/open-questions.md`, `backend/docs/domain-model.md` and `frontend/docs/*.md`.
4. Present ONE plan for the whole milestone: backend tasks (migrations, modules, endpoints, tests), frontend tasks (screens, providers, routes, tests), any contract changes, open questions that affect it, and the demo script. Wait for my "go".
5. After "go": do the tasks in order (backend, then frontend). Work on one branch for the milestone (`be/M4-…` / `fe/M4-…`, from an up-to-date `main`). For each task: mark `[~]`, implement, run the side's tests, mark `[x] (date)`, commit on that branch. Do not ask between tasks unless CLAUDE.md §4 step 4 applies.
6. At the end: run both test suites and `/sync-check`, mark the milestone `[x]` in `ROADMAP.md`, write the progress-log entry, push the branch, open a pull request for review (never push to `main`), and give me the demo script and the PR link.
