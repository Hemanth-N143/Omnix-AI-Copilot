package com.ai.copilot.service;

import com.ai.copilot.entity.ChatSession;
import com.ai.copilot.entity.Message;
import com.ai.copilot.repository.ChatSessionRepository;
import com.ai.copilot.repository.MessageRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.client.RestTemplate;

import java.time.Instant;
import java.util.*;

@Service
public class ChatService {

    private static final Logger log = LoggerFactory.getLogger(ChatService.class);

    private final ChatSessionRepository chatSessionRepository;
    private final MessageRepository messageRepository;
    private final RestTemplate restTemplate;

    @Value("${ai.api.key:}")
    private String apiKey;

    @Value("${ai.api.url}")
    private String apiUrl;

    public ChatService(ChatSessionRepository chatSessionRepository, MessageRepository messageRepository) {
        this.chatSessionRepository = chatSessionRepository;
        this.messageRepository = messageRepository;
        this.restTemplate = new RestTemplate();
    }

    /** 🟢 Start new chat session */
    public String startNewSession() {
        String sessionId = UUID.randomUUID().toString();
        ChatSession session = new ChatSession();
        session.setSessionId(sessionId);
        session.setCreatedAt(Instant.now());
        session.setTitle("Chat " + (chatSessionRepository.count() + 1));
        chatSessionRepository.save(session);

        log.info("🟢 New session created: {} ({})", session.getTitle(), sessionId);
        return sessionId;
    }

    /** 📋 List all chat sessions */
    public List<ChatSession> listSessions() {
        List<ChatSession> sessions = chatSessionRepository.findAll();
        log.debug("📋 Found {} sessions in DB", sessions.size());
        return sessions;
    }

    /** 📜 Load chat history */
    public List<Message> getHistory(String sessionId) {
        List<Message> messages = messageRepository.findBySessionIdOrderByTimestampAsc(sessionId);
        log.debug("📜 Loaded {} messages for session [{}]", messages.size(), sessionId);
        return messages;
    }

    /** 💬 Send message & get AI response */
    public String sendMessage(String sessionId, String userContent) {
        ensureSessionExists(sessionId);

        // Save user message
        Message userMsg = new Message();
        userMsg.setSessionId(sessionId);
        userMsg.setRole("USER");
        userMsg.setContent(userContent);
        userMsg.setTimestamp(Instant.now());
        messageRepository.save(userMsg);

        log.info("💬 User message saved [{}]: {}", sessionId, userContent);

        // Call Gemini API
        String aiResponse = callGemini(userContent);

        // Save AI response
        Message aiMsg = new Message();
        aiMsg.setSessionId(sessionId);
        aiMsg.setRole("AI");
        aiMsg.setContent(aiResponse);
        aiMsg.setTimestamp(Instant.now());
        messageRepository.save(aiMsg);

        log.info("🤖 AI response saved [{}]: {}", sessionId, aiResponse);
        return aiResponse;
    }

    /** 🧠 Ensure session exists before message saving */
    private void ensureSessionExists(String sessionId) {
        if (sessionId == null || sessionId.isBlank()) {
            throw new IllegalArgumentException("Session ID is required");
        }

        if (!chatSessionRepository.existsBySessionId(sessionId)) {
            log.warn("⚠️ Session not found: {}", sessionId);
            throw new NoSuchElementException("Session not found: " + sessionId);
        }
    }

    /** 🤖 Call Gemini API with safety and debug logging */
    private String callGemini(String prompt) {
        if (apiKey == null || apiKey.isBlank()) {
            log.warn("⚠️ No API key found — returning mock response");
            return "[DEV MODE] Echo: " + prompt;
        }

        String urlWithKey = apiUrl + "?key=" + apiKey;

        Map<String, Object> textPart = Map.of("text", prompt);
        Map<String, Object> content = Map.of("parts", List.of(textPart));
        Map<String, Object> requestBody = Map.of("contents", List.of(content));

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);

        HttpEntity<Map<String, Object>> entity = new HttpEntity<>(requestBody, headers);

        try {
            Map<String, Object> response = restTemplate.postForObject(urlWithKey, entity, Map.class);

            if (response == null || !response.containsKey("candidates")) {
                log.error("❌ No valid response from Gemini API");
                return "No response from AI.";
            }

            List<Map<String, Object>> candidates = (List<Map<String, Object>>) response.get("candidates");
            if (candidates == null || candidates.isEmpty()) {
                return "No candidates found.";
            }

            Map<String, Object> contentResp = (Map<String, Object>) candidates.get(0).get("content");
            if (contentResp == null || !contentResp.containsKey("parts")) {
                return "No content parts found.";
            }

            List<Map<String, Object>> partsResp = (List<Map<String, Object>>) contentResp.get("parts");
            String reply = String.valueOf(partsResp.get(0).get("text"));

            log.debug("✅ Gemini API reply: {}", reply);
            return reply;

        } catch (Exception e) {
            log.error("🔥 Error calling Gemini API: {}", e.getMessage(), e);
            return "Error calling Gemini API: " + e.getMessage();
        }
    }

    /** 🗑 Delete session and all messages */
    @Transactional
    public boolean deleteSession(String sessionId) {
        if (sessionId == null || sessionId.isBlank()) {
            log.error("❌ deleteSession failed: blank sessionId");
            return false;
        }

        Optional<ChatSession> sessionOpt = chatSessionRepository.findBySessionId(sessionId);
        if (sessionOpt.isEmpty()) {
            log.warn("⚠️ No chat found for ID {}", sessionId);
            return false;
        }

        try {
            messageRepository.deleteAllBySessionId(sessionId);
            chatSessionRepository.deleteBySessionId(sessionId);
            log.info("🧹 Deleted session [{}] and all related messages", sessionId);
            return true;
        } catch (Exception e) {
            log.error("🔥 Failed to delete chat session {}: {}", sessionId, e.getMessage(), e);
            throw new IllegalStateException("Failed to delete chat session: " + sessionId, e);
        }
    }

    /** ✏️ Rename chat session title */
    public void renameSession(String sessionId, String newTitle) {
        Optional<ChatSession> optionalSession = chatSessionRepository.findBySessionId(sessionId);
        if (optionalSession.isPresent()) {
            ChatSession session = optionalSession.get();
            session.setTitle(newTitle);
            chatSessionRepository.save(session);
            log.info("✏️ Session [{}] renamed to '{}'", sessionId, newTitle);
        } else {
            log.warn("⚠️ Session not found for rename: {}", sessionId);
            throw new NoSuchElementException("Session not found: " + sessionId);
        }
    }
}
