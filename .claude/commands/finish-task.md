---
description: Verify, close, log and commit the current task
---

1. Run the checks for the side you changed — backend: `cd backend && ./mvnw verify`; frontend: `cd frontend && flutter analyze && flutter test`. Fix failures first; never skip tests.
2. Re-check the rules in `CLAUDE.md` §3 and the side's `CLAUDE.md` §3.
3. Mark the task `[x] (today)` in the side's `TODO.md` and update the phase "Done" count.
4. Update today's entry in `docs/progress-log.md` (Done / In progress / Blocked / Contract changes / Notes).
5. If `docs/api-contract.md` changed, make sure the other side has a task for it.
6. New decisions → `docs/decisions.md`; new questions → `docs/open-questions.md`.
7. Commit on the task branch, never on `main` (`feat(backend|frontend): <ID> <title>`), push the branch and open or update its pull request (CLAUDE.md §4 Git workflow). Give me a 3-line summary with the PR link.
