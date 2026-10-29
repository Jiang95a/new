package com.campus.server.service;

import com.campus.server.dto.Dtos;
import com.campus.server.mapper.MiscMapper;
import com.campus.server.mapper.SubmissionMapper;
import com.campus.server.support.Ids;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;

/**
 * 项目数据看板：提交数、有效提交数、浏览量、发布页数、按天趋势、分事件统计。
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
        long formStarted = miscMapper.countEvent(projectId, "form_started");

        // byDay 以前是空的（只聚合了 form_submissions，而新项目还没有提交）。
        // 现在把「提交」和「浏览」两条线合并到同一张按天的表里，前端画曲线才有东西。
        Map<String, long[]> merged = new TreeMap<>();
        for (Map<String, Object> row : miscMapper.submissionsByDay(projectId)) {
            long[] slot = merged.computeIfAbsent(dayOf(row), k -> new long[2]);
            slot[0] = toLong(row.get("c"));
        }
        for (Map<String, Object> row : miscMapper.viewsByDay(projectId)) {
            long[] slot = merged.computeIfAbsent(dayOf(row), k -> new long[2]);
            slot[1] = toLong(row.get("c"));
        }

        List<Map<String, Object>> byDay = new ArrayList<>(merged.size());
        for (Map.Entry<String, long[]> entry : merged.entrySet()) {
            if (entry.getKey().isEmpty()) {
                continue;
            }
            Map<String, Object> item = new LinkedHashMap<>();
            item.put("date", entry.getKey());
            item.put("submissions", entry.getValue()[0]);
            item.put("views", entry.getValue()[1]);
            // 兼容旧字段：早期前端按 count 读「当天提交数」
            item.put("count", entry.getValue()[0]);
            byDay.add(item);
        }

        Map<String, Long> byEventType = new LinkedHashMap<>();
        for (Map<String, Object> row : miscMapper.eventsGrouped(projectId)) {
            Object type = row.get("t");
            if (type != null) {
                byEventType.put(String.valueOf(type), toLong(row.get("c")));
            }
        }

        double conversion = formStarted > 0
                ? Math.round(valid * 10000.0 / formStarted) / 10000.0
                : 0.0;

        return new Dtos.AnalyticsSummaryDto(total, valid, views, publishedPages,
                byDay, byEventType, formStarted, conversion);
    }

    /** 事件明细：分页返回原始埋点，可按 eventType 过滤。 */
    public Dtos.PagedResultHolder<Dtos.ActivityEventDto> events(String projectId, String eventType,
                                                                int page, int pageSize) {
        projectService.loadOwned(projectId);
        int safePage = Math.max(page, 1);
        int safeSize = Math.min(Math.max(pageSize, 1), 200);
        String type = (eventType == null || eventType.isBlank()) ? null : eventType;

        long total = miscMapper.countEvents(projectId, type);
        if (total == 0) {
            return new Dtos.PagedResultHolder<>(List.of(), new Dtos.PageMeta(safePage, safeSize, 0));
        }
        List<Dtos.ActivityEventDto> data = miscMapper
                .listEvents(projectId, type, safeSize, (safePage - 1) * safeSize)
                .stream()
                .map(e -> new Dtos.ActivityEventDto(
                        e.getId() == null ? null : String.valueOf(e.getId()),
                        e.getEventType(),
                        e.getPageId(),
                        e.getMetadata(),
                        Ids.iso(e.getOccurredAt())))
                .toList();
        return new Dtos.PagedResultHolder<>(data, new Dtos.PageMeta(safePage, safeSize, total));
    }

    private static String dayOf(Map<String, Object> row) {
        Object day = row.get("d");
        return day == null ? "" : String.valueOf(day);
    }

    private static long toLong(Object value) {
        if (value == null) {
            return 0L;
        }
        if (value instanceof Number number) {
            return number.longValue();
        }
        try {
            return Long.parseLong(String.valueOf(value));
        } catch (NumberFormatException ex) {
            return 0L;
        }
    }
}
