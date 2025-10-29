-- Detect rows in chat_sessions with empty or NULL session_id
SELECT id, session_id, title, created_at
FROM chat_sessions
WHERE session_id IS NULL OR TRIM(session_id) = '';

-- If you're confident, you can remove such rows (run after a backup):
-- DELETE FROM message WHERE session_id IS NULL OR TRIM(session_id) = '';
-- DELETE FROM chat_sessions WHERE session_id IS NULL OR TRIM(session_id) = '';

-- Optionally inspect related messages count per invalid session id before delete:
-- SELECT session_id, COUNT(*) FROM message WHERE session_id IS NULL OR TRIM(session_id) = '' GROUP BY session_id;

