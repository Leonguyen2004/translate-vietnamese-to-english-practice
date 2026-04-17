package com.lmh.web.dto.response.quiz;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class QuizQuestionResponse {
    private String questionId;
    private String question;
    private List<String> options;
    private String correctAnswer;
    private boolean isCorrect;
    private String message;
    private boolean isCompleted;
    private Integer currentQuestionNumber;
    private Integer totalQuestions;
}

