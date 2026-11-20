---
description: Check that backend and frontend code still match docs/api-contract.md
---

Do not modify files. Compare `docs/api-contract.md` with:
- `backend/`: controllers, request/response DTOs, enums and error codes (and `/v3/api-docs` if the app is running);
- `frontend/`: `lib/shared/models`, `features/*/data` API classes, error-code mapping.
Report a table: item · contract · backend · frontend · action needed. End with "in sync" or the list of fixes, each as a proposed task ID.
