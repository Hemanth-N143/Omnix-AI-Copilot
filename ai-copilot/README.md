AI Copilot — Local run & test

Overview
--------
Small Spring Boot chat application (JSP UI + JPA). This repo includes fixes to avoid frontend 404s for missing session IDs, test harness using H2, and a small SQL script to detect/clean invalid DB rows.

Quick run (Windows)
-------------------
1) Build (optional):

```cmd
.\mvnw.cmd -DskipTests package
```

2) Run:

```cmd
.\mvnw.cmd -DskipTests spring-boot:run
```

Open http://localhost:9090/chat

Run tests (uses in-memory H2):

```cmd
.\mvnw.cmd test
```

What I added
------------
- Frontend defensive checks in `src/main/webapp/WEB-INF/views/chat.jsp` to avoid calls to `/api/copilot/history/` or `/api/copilot/delete/` without a session ID.
- Backend handlers in `src/main/java/com/ai/copilot/controller/ChatController.java` to return 400 JSON when `/history` or `/delete` are called without a path variable (helps debugging).
- `ViewController` now serves `/favicon.ico` with 204 No Content to silence 404 noise in the browser console.
- Integration tests: `src/test/java/com/ai/copilot/controller/ChatControllerWebTest.java` (uses MockMvc and H2 in-memory DB).
- Test config: `src/test/resources/application.properties` to use H2 (create-drop) for tests.
- SQL helper: `tools/cleanup-empty-sessions.sql` — find and optionally delete rows with empty `session_id`.

Notes
-----
- Tests use H2 by default so you don't need a running MySQL instance to run them locally.
- If you prefer an actual favicon file, drop `favicon.ico` into `src/main/resources/static/` — currently the app serves 204 for `/favicon.ico`.

If you'd like I can:
- Run the server here and stream logs while you click around the UI (if you want log traces), or
- Prepare a small Flyway migration to enforce NOT NULL on `session_id` and clean invalid rows.


