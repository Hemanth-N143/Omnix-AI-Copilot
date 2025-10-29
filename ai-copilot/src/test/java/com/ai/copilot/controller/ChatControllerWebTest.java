package com.ai.copilot.controller;

import com.ai.copilot.entity.ChatSession;
import com.ai.copilot.entity.Message;
import com.ai.copilot.repository.ChatSessionRepository;
import com.ai.copilot.repository.MessageRepository;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import java.time.Instant;

import static org.hamcrest.Matchers.containsString;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
public class ChatControllerWebTest {

    private final MockMvc mockMvc;
    private final ChatSessionRepository chatSessionRepository;
    private final MessageRepository messageRepository;

    private ChatSession session;

    @Autowired
    public ChatControllerWebTest(MockMvc mockMvc, ChatSessionRepository chatSessionRepository, MessageRepository messageRepository) {
        this.mockMvc = mockMvc;
        this.chatSessionRepository = chatSessionRepository;
        this.messageRepository = messageRepository;
    }

    @BeforeEach
    void setup() {
        messageRepository.deleteAll();
        chatSessionRepository.deleteAll();

        session = new ChatSession();
        session.setSessionId("test-session-123");
        session.setTitle("Test Session");
        session.setCreatedAt(Instant.now());
        chatSessionRepository.save(session);

        Message msg = new Message();
        msg.setSessionId(session.getSessionId());
        msg.setRole("USER");
        msg.setContent("Hello");
        msg.setTimestamp(Instant.now());
        messageRepository.save(msg);
    }

    @AfterEach
    void tearDown() {
        messageRepository.deleteAll();
        chatSessionRepository.deleteAll();
    }

    @Test
    void historyWithSessionIdReturnsMessages() throws Exception {
        mockMvc.perform(get("/api/copilot/history/" + session.getSessionId())
                        .accept(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(content().contentTypeCompatibleWith(MediaType.APPLICATION_JSON))
                .andExpect(content().string(containsString("Hello")));
    }

    @Test
    void historyWithoutSessionIdReturnsBadRequest() throws Exception {
        mockMvc.perform(get("/api/copilot/history")
                        .accept(MediaType.APPLICATION_JSON))
                .andExpect(status().isBadRequest())
                .andExpect(content().string(containsString("Missing sessionId")));
    }

    @Test
    void deleteWithoutSessionIdReturnsBadRequest() throws Exception {
        mockMvc.perform(delete("/api/copilot/delete")
                        .accept(MediaType.APPLICATION_JSON))
                .andExpect(status().isBadRequest())
                .andExpect(content().string(containsString("Missing sessionId")));
    }

    @Test
    void deleteWithSessionIdDeletes() throws Exception {
        // ensure session exists
        String sid = session.getSessionId();
        mockMvc.perform(delete("/api/copilot/delete/" + sid)
                        .accept(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(content().contentTypeCompatibleWith(MediaType.APPLICATION_JSON))
                .andExpect(content().string(containsString("success")));

        // Verify session removed
        org.junit.jupiter.api.Assertions.assertFalse(chatSessionRepository.findBySessionId(sid).isPresent());
        // Verify messages removed
        org.junit.jupiter.api.Assertions.assertTrue(messageRepository.findBySessionIdOrderByTimestampAsc(sid).isEmpty());
    }
}
