package com.ai.copilot.repository;

import com.ai.copilot.entity.Message;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface MessageRepository extends JpaRepository<Message, Long> {
    List<Message> findBySessionIdOrderByTimestampAsc(String sessionId);
    void deleteAllBySessionId(String sessionId);
}
