# CLAUDE.md — Tranix (project root)

Claude Code is run **from this folder**. This file is read first; `backend/CLAUDE.md` and `frontend/CLAUDE.md` add rules for each side and are read when working there.

## 1. Project

**Tranix** — a verified road-freight platform for India (Load Providers, Farmer Networks, Drivers, Organizations, Receivers, Admin).

```
<project-root>/
├── CLAUDE.md            ← this file: project-wide rules + how Claude works
├── ROADMAP.md           ← milestone order across backend + frontend (what to build next)
├── docs/                ← shared, single copy
│   ├── product-spec.md     business rules (authoritative)
│   ├── api-contract.md     the only agreement between backend and frontend
│   ├── decisions.md        final decisions D-01…
│   ├── open-questions.md   undecided items + safe defaults
│   └── progress-log.md     one entry per session
├── backend/             ← Spring Boot (Java 21) — CLAUDE.md, TODO.md (B-xxx), docs/domain-model.md
└── frontend/            ← Flutter (Android first) — CLAUDE.md, TODO.md (A-xxx), docs/screens.md, architecture.md, ui-guidelines.md
```
Folder names checked on 2026-11-21: `backend/` and `frontend/` (renamed from `tranix-backend`/`tranix-frontend`). One git repo for the whole project: `NOTHING-Tranix/tranix` (private).
On this Windows machine use `mvnw.cmd` in `backend/`, with `JAVA_HOME` = JDK 21 (the default `java` on PATH is 24).

## 2. Source of truth and precedence

`docs/decisions.md` > `docs/product-spec.md` > `docs/api-contract.md` > side-specific docs > code.
**Never invent business rules.** Missing rule → ask the founder (Tharun), then record the answer in `docs/decisions.md`.

## 3. Project-wide rules

1. **Contract first:** any API change is made in `docs/api-contract.md` first, then backend, then frontend. Both sides must match exactly (names, enums, error codes).
2. The server decides everything that matters (eligibility, charges, statuses, Trust Score, wish-list windows); the app shows results and sends intent.
3. Privacy: no full Aadhaar anywhere; phone numbers and exact locations only after acceptance; no tokens/OTPs/phone numbers in logs.
4. Fake implementations for outside services until the real ones are decided (`docs/open-questions.md`).
5. Tests must pass before anything is marked done: backend `./mvnw verify` (in `backend/`), frontend `flutter analyze && flutter test` (in `frontend/`).
6. Never commit secrets (`.env`, `application-local.yml`, keystores, `google-services.json` for prod).
7. Never run destructive commands (dropping databases, deleting folders, force-push, rewriting git history) without asking.

## 4. How Claude works here (autopilot with checkpoints)

The founder wants Claude to drive the work. Use this loop:

1. **Start of session:** read `ROADMAP.md`, the latest `docs/progress-log.md` entry, and the TODO of the side(s) in the current milestone. Say in 3 lines where things stand and what you will do next.
2. **Milestone plan (checkpoint):** at the start of a milestone, show one plan for the whole milestone (backend tasks, frontend tasks, contract changes, tests) and wait for "go".
3. **Execute without asking per task:** after "go", work through the milestone's tasks in order — backend first, then frontend for the same feature — marking each `[~]` then `[x] (date)`, running tests, and committing after each task (`feat(backend): B-403 …`, `feat(frontend): A-402 …`).
4. **Stop and ask only when:** an open question blocks you; the contract needs a change not covered by the spec; tests keep failing after 3 honest attempts; a destructive or paid action is needed (cloud resources, real SMS/payment keys); or the milestone is done.
5. **End of milestone (checkpoint):** run both test suites, run `/sync-check`, update `ROADMAP.md` status, write a progress-log entry, and give the founder a short demo script (what to tap/call to see it working).
6. Keep each commit small and working. If the session ends mid-task, leave `[~]` and a progress-log note so the next session resumes.

## 5. Running things

```bash
# backend
cd backend && docker compose up -d && ./mvnw spring-boot:run -Dspring-boot.run.profiles=dev
# frontend (Android emulator → local backend)
cd frontend && flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080/api/v1
# frontend without backend
cd frontend && flutter run --dart-define=USE_MOCK=true
```
Swagger UI (admin actions until the admin panel exists): `http://localhost:8080/swagger-ui.html`. Dev OTP is `123456` (dev profile only).

## 6. Commands

`/status` · `/next-milestone` · `/next-task [ID]` · `/finish-task` · `/sync-check`
