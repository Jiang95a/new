package com.campus.server.web;

import com.campus.server.common.ApiResponse;
import com.campus.server.dto.Dtos;
import com.campus.server.service.FeedbackService;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/feedback")
public class FeedbackController {

    private final FeedbackService feedbackService;

    public FeedbackController(FeedbackService feedbackService) {
        this.feedbackService = feedbackService;
    }

    @PostMapping
    public ApiResponse.Envelope<Dtos.FeedbackResult> submit(@Valid @RequestBody Dtos.FeedbackRequest request) {
        return ApiResponse.ok(feedbackService.submit(request));
    }
}
