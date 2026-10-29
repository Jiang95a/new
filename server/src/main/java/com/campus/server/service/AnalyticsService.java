package com.campus.server.service;

import com.campus.server.dto.Dtos;
import com.campus.server.mapper.MiscMapper;
import com.campus.server.mapper.SubmissionMapper;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * 项目数据看板：提交数、有效提交数、浏览量、发布页数、按天趋势。
 * 所有统计前先 loadOwned，保证越权查别人的项目会直接 403。
 */
@Service
public class AnalyticsService {

    private final MiscMapper miscMapper;
    private final SubmissionMapper submissionMapper;
    private final ProjectService projectService;

    public AnalyticsService(MiscMapper miscMapper,
                            SubmissionMapper submissionMapper,
                            ProjectService projectService) {
        this.miscMapper = miscMapper;
        this.submissionMapper = submissionMapper;
        this.projectService = projectService;
    }

    public Dtos.AnalyticsSummaryDto summary(String projectId) {
        projectService.loadOwned(projectId);

        long total = submissionMapper.count(projectId, null);
        long valid = submissionMapper.countValid(projectId);
        long views = miscMapper.countEvent(projectId, "public_page_view");
        long publishedPages = miscMapper.countDistinctViewedPages(projectId);

        List<Map<String, Object>> rows = miscMapper.submissionsByDay(projectId);
        List<Map<String, Object>> byDay = new ArrayList<>();
        for (Map<String, Object> row : rows) {
            Map<String, Object> item = new LinkedHashMap<>();
            Object day = row.get("d");
            item.put("date", day == null ? "" : String.valueOf(day));
            Object count = row.get("c");
            item.put("count", count == null ? 0 : ((Number) count).longValue());
            byDay.add(item);
        }

        return new Dtos.AnalyticsSummaryDto(total, valid, views, publishedPages, byDay);
    }
}
