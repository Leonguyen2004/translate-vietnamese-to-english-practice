package com.lmh.web.service.user;

import com.lmh.web.model.QuizSession;

import java.util.Map;

public interface QuizSessionManager {
    void storeSession(String sessionId, QuizSession session);
    QuizSession getSession(String sessionId);
    void removeSession(String sessionId);
    Map<String, QuizSession> getAllSessions();
    void cleanupExpiredSessions();
}

