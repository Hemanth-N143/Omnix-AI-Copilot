package com.ai.copilot.controller;

import com.ai.copilot.dto.SessionSummary;
import com.ai.copilot.entity.ChatSession;
import com.ai.copilot.entity.Message;
import com.ai.copilot.service.ChatService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.util.*;

@RestController
@RequestMapping("/api/copilot")
@Validated
public class ChatController {

    private static final Logger log = LoggerFactory.getLogger(ChatController.class);
    private final ChatService chatService;

    public ChatController(ChatService chatService) {
        this.chatService = chatService;
    }

    /**  🟢 Create new chat session */
    @PostMapping(value = "/new", produces = MediaType.APPLICATION_JSON_VALUE)
    public Map<String, String> startNew() {
        log.info("🟢 Request to start new chat session");
        String sessionId = chatService.startNewSession();
        log.info("✅ New chat session created -> {}", sessionId);
        return Map.of("sessionId", sessionId);
    }

    /** 📋 List all chat sessions (typed DTO) */
    @GetMapping(value = "/sessions", produces = MediaType.APPLICATION_JSON_VALUE)
    public List<SessionSummary> sessions() {
        log.debug("📋 Fetching all chat sessions...");
        List<ChatSession> sessions = chatService.listSessions();
        log.debug("📋 Found {} chat sessions in DB", sessions.size());
        sessions.forEach(s -> log.debug("➡️ {}", s.getSessionId()));

        return sessions.stream()
                .sorted(Comparator.comparing(ChatSession::getCreatedAt).reversed())
                .map(s -> new SessionSummary(s.getSessionId(), s.getTitle(), s.getCreatedAt().toString()))
                .toList();
    }

    /** 📜 Fetch chat history for given session */
    @GetMapping(value = "/history/{sessionId}", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<?> history(@PathVariable String sessionId) {
        log.debug("📜 Fetching history for session {}", sessionId);
        List<Message> messages = chatService.getHistory(sessionId);

        if (messages.isEmpty()) {
            log.warn("⚠️ No messages found for session {}", sessionId);
        }
        return ResponseEntity.ok(messages);
    }

    /** 📜 Handle missing sessionId in URL for history (return 400 instead of 404) */
    @GetMapping(value = "/history", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<Map<String, String>> historyMissing() {
        log.warn("⚠️ History endpoint called without sessionId");
        return ResponseEntity.badRequest().body(Map.of("error", "Missing sessionId in path"));
    }

    /** 💬 Chat endpoint for message exchange */
    public static class ChatRequest {
        public String sessionId;
        public String message;

        public String getSessionId() { return sessionId; }
        public void setSessionId(String sessionId) { this.sessionId = sessionId; }

        public String getMessage() { return message; }
        public void setMessage(String message) { this.message = message; }
    }

    @PostMapping(value = "/chat", consumes = MediaType.APPLICATION_JSON_VALUE, produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<Map<String, String>> chat(@RequestBody ChatRequest request) {
        if (request == null || request.sessionId == null || request.message == null) {
            log.error("❌ Invalid chat request received: {}", request);
            return ResponseEntity.badRequest().body(Map.of("reply", "Invalid request."));
        }

        log.info("💬 Message received [{}]: {}", request.sessionId, request.message);
        try {
            String reply = chatService.sendMessage(request.sessionId, request.message);
            return ResponseEntity.ok(Map.of("reply", reply));
        } catch (NoSuchElementException e) {
            log.warn("⚠️ Chat failed - session not found: {}", request.sessionId);
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("reply", "Session not found."));
        } catch (IllegalArgumentException e) {
            log.error("❌ Chat failed - invalid request: {}", e.getMessage());
            return ResponseEntity.badRequest().body(Map.of("reply", "Invalid request."));
        } catch (Exception e) {
            log.error("🔥 Chat failed unexpectedly: {}", e.getMessage(), e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(Map.of("reply", "Server error."));
        }
    }

    /** 🗑 Delete chat session */
    @DeleteMapping("/delete/{sessionId}")
    public ResponseEntity<Map<String, String>> deleteChat(@PathVariable String sessionId) {
        if (sessionId == null || sessionId.isEmpty()) {
            log.warn("❌ Delete request received with missing sessionId");
            return ResponseEntity.badRequest().body(Map.of("status", "failed", "message", "Missing sessionId"));
        }

        log.info("🗑 Request to delete chat [{}]", sessionId);
        try {
            boolean deleted = chatService.deleteSession(sessionId);

            if (deleted) {
                log.info("✅ Chat deleted successfully [{}]", sessionId);
                return ResponseEntity.ok(Map.of("status", "success", "message", "Chat deleted successfully"));
            } else {
                log.warn("⚠️ Chat not found or already deleted [{}]", sessionId);
                return ResponseEntity.status(404).body(Map.of("status", "failed", "message", "Chat not found"));
            }
        } catch (Exception e) {
            // Log the exception with stack trace for diagnosis, but return a safe message to the client
            log.error("🔥 Failed to delete chat [{}]: {}", sessionId, e.getMessage(), e);
            Map<String, String> body = new HashMap<>();
            body.put("status", "failed");
            body.put("message", "Server error while deleting chat");
            // include error detail to assist debugging (dev-only)
            body.put("error", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(body);
        }
    }

    /** 🗑 Handle delete without sessionId in path */
    @DeleteMapping(value = "/delete", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<Map<String, String>> deleteMissing() {
        log.warn("⚠️ Delete endpoint called without sessionId");
        return ResponseEntity.badRequest().body(Map.of("status", "failed", "message", "Missing sessionId"));
    }

    @PostMapping("/rename/{sessionId}")
    public ResponseEntity<?> renameChatSession(@PathVariable String sessionId, @RequestBody Map<String, String> body) {
        String title = body.get("title");
        chatService.renameSession(sessionId, title);
        return ResponseEntity.ok().build();
    }

}
