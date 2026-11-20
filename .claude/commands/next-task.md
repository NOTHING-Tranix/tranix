---
description: Do a single task (B-xxx or A-xxx), or the next one in the current milestone
---

1. Read `CLAUDE.md`, `ROADMAP.md` and the latest `docs/progress-log.md` entry.
2. Use the task ID in `$ARGUMENTS` (B- = `backend/TODO.md`, A- = `frontend/TODO.md`), else the next `[ ]` task of the current milestone.
3. Check `docs/open-questions.md` / `docs/decisions.md`; if truly blocked mark `[!]` and explain.
4. Mark `[~]`, read the relevant docs, show a short plan and wait for approval (skip the wait if I said "go ahead" for this milestone).
5. Implement, test (`./mvnw verify` in backend / `flutter analyze && flutter test` in frontend), mark `[x] (date)`, update the phase count, add a progress-log line, commit.
