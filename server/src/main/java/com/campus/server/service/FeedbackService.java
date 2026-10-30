package com.campus.server.service;

import com.campus.server.dto.Dtos;
import com.campus.server.entity.MiscEntities.FeedbackReportEntity;
import com.campus.server.mapper.MiscMapper;
import com.campus.server.security.CurrentUser;
import com.campus.server.support.Ids;
import org.springframework.stereotype.Service;

@Service
public class FeedbackService {

    private final MiscMapper miscMapper;

    public FeedbackService(MiscMapper miscMapper) {
        this.miscMapper = miscMapper;
    }

    public Dtos.FeedbackResult submit(Dtos.FeedbackRequest request) {
        FeedbackReportEntity feedback = new FeedbackReportEntity();
        feedback.setId(Ids.uuid());
        feedback.setUserId(CurrentUser.require().userId());
        feedback.setCategory(request.category() == null || request.category().isBlank()
                ? "other" : request.category().trim());
        feedback.setContent(request.content().trim());
        feedback.setContact(request.contact() == null ? null : request.contact().trim());
        feedback.setStatus("open");
        miscMapper.insertFeedback(feedback);
        return new Dtos.FeedbackResult(feedback.getId(), feedback.getStatus(), Ids.nowIso());
    }
}
