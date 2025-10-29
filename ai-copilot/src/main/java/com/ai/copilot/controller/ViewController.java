package com.ai.copilot.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class ViewController {

    @GetMapping({"/", "/chat"})
    public String chat() {
        return "chat"; // resolves to /WEB-INF/jsp/chat.jsp
    }

    // Serve a no-content response for favicon requests to avoid noisy 404 in browser console
    @GetMapping("/favicon.ico")
    public ResponseEntity<Void> favicon() {
        return ResponseEntity.noContent().build();
    }
}
