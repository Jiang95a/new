package com.campus.server.web;

import com.campus.server.common.ApiResponse;
import com.campus.server.dto.Dtos;
import com.campus.server.service.AnalyticsService;
import com.campus.server.service.ExportService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

/** 数据看板 + 报名数据导出。 */
@RestController
public class AnalyticsController {

    private final AnalyticsService analyticsService;
    private final ExportService exportService;

    public AnalyticsController(AnalyticsService analyticsService, ExportService exportService) {
        this.analyticsService = analyticsService;
        this.exportService = exportService;
    }

    @GetMapping("/projects/{projectId}/analytics/summary")
    public ApiResponse.Envelope<Dtos.AnalyticsSummaryDto> summary(@PathVariable String projectId) {
        return ApiResponse.ok(analyticsService.summary(projectId));
    }

    /** 埋点明细：浏览 / 开始填写 / 提交等原始事件，分页。 */
    @GetMapping("/projects/{projectId}/analytics/events")
    public ApiResponse.PagedEnvelope<java.util.List<Dtos.ActivityEventDto>> events(
            @PathVariable String projectId,
            @RequestParam(required = false) String eventType,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int pageSize) {
        Dtos.PagedResultHolder<Dtos.ActivityEventDto> result =
                analyticsService.events(projectId, eventType, page, pageSize);
        return ApiResponse.page(result.data(), result.meta().total(),
                result.meta().page(), result.meta().pageSize());
    }

    /** 发起导出，V1 同步生成 CSV，返回的 status 直接就是 succeeded / failed。 */
    @PostMapping("/projects/{projectId}/exports")
    public ApiResponse.Envelope<Dtos.ExportJobDto> createExport(@PathVariable String projectId) {
        return ApiResponse.ok(exportService.create(projectId));
    }

    @GetMapping("/projects/{projectId}/exports")
    public ApiResponse.Envelope<java.util.List<Dtos.ExportJobDto>> listExports(@PathVariable String projectId) {
        return ApiResponse.ok(exportService.list(projectId));
    }

    @GetMapping("/exports/{exportId}")
    public ApiResponse.Envelope<Dtos.ExportJobDto> getExport(@PathVariable String exportId) {
        return ApiResponse.ok(exportService.get(exportId));
    }

    /** 拿到下载地址（本地部署时是 /api/v1/files/...）。 */
    @GetMapping("/exports/{exportId}/download")
    public ApiResponse.Envelope<Map<String, Object>> download(@PathVariable String exportId) {
        return ApiResponse.ok(Map.of("url", exportService.downloadUrl(exportId)));
    }
}
