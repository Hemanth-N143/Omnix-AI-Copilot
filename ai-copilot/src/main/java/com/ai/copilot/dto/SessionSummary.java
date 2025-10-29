package com.ai.copilot.dto;

public class SessionSummary {
    private String sessionId;
    private String title;
    private String createdAt; // ISO-8601 string

    public SessionSummary() {}

    public SessionSummary(String sessionId, String title, String createdAt) {
        this.sessionId = sessionId;
        this.title = title;
        this.createdAt = createdAt;
    }

    public String getSessionId() { return sessionId; }
    public void setSessionId(String sessionId) { this.sessionId = sessionId; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getCreatedAt() { return createdAt; }
    public void setCreatedAt(String createdAt) { this.createdAt = createdAt; }
}

