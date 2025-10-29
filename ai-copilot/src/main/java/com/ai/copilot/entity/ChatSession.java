package com.ai.copilot.entity;

import jakarta.persistence.*;
import java.time.Instant;

@Entity
@Table(name = "chat_sessions")
public class ChatSession {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "session_id", nullable = false, unique = true, length = 255)
    private String sessionId;

    @Column(name = "title", nullable = false, length = 255)
    private String title = "New Chat";

    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt = Instant.now();

    // ===== Constructors =====
    public ChatSession() {}

    public ChatSession(String sessionId, String title) {
        this.sessionId = sessionId;
        this.title = title;
        this.createdAt = Instant.now();
    }

    // ===== Getters & Setters =====
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getSessionId() { return sessionId; }
    public void setSessionId(String sessionId) { this.sessionId = sessionId; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public Instant getCreatedAt() { return createdAt; }
    public void setCreatedAt(Instant createdAt) { this.createdAt = createdAt; }

    // ===== Debug Log Helper =====
    @Override
    public String toString() {
        return String.format("ChatSession[id=%d, sessionId=%s, title=%s, createdAt=%s]",
                id, sessionId, title, createdAt);
    }
}
