package com.campus.server.web;

import com.campus.server.common.ApiResponse;
import com.campus.server.dto.Dtos;
import com.campus.server.service.ProjectService;
import com.campus.server.service.SubmissionService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

/**
 * 公开活动页：不需要登录，任何人凭 slug 访问。
 *
 * <p>对应前端 {@code web/src/views/PublicActivityView.vue}。
 * 注意 {@code /public/**} 在 AuthInterceptor 里是放行的。
 */
@RestController
@RequestMapping("/public")
public class PublicController {

    private final ProjectService projectService;
    private final SubmissionService submissionService;

    public PublicController(ProjectService projectService, SubmissionService submissionService) {
        this.projectService = projectService;
        this.submissionService = submissionService;
    }

    /** 打开活动页：返回发布时的文档快照（不是草稿），并记一次浏览埋点。 */
    @GetMapping("/activities/{slug}")
    public ApiResponse.Envelope<Dtos.PublicActivityDto> getActivity(@PathVariable String slug) {
        return ApiResponse.ok(projectService.getPublic(slug, true));
    }

    /**
     * 公开活动列表：已发布的活动，任何人可看。
     * 只返回白名单字段（slug / 标题 / 封面四项 / 状态 / 更新时间），不带草稿内容。
     */
    @GetMapping("/activities")
    public ApiResponse.PagedEnvelope<java.util.List<Dtos.PublicActivitySummaryDto>> listActivities(
            @RequestParam(required = false) String q,
            @RequestParam(required = false) String activityType,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int pageSize) {
        Dtos.PagedResultHolder<Dtos.PublicActivitySummaryDto> result =
                projectService.listPublic(q, activityType, page, pageSize);
        return ApiResponse.page(result.data(), result.meta().total(),
                result.meta().page(), result.meta().pageSize());
    }

    /**
     * 提交报名。
     * 幂等：同一个 idempotencyKey 重复提交返回同一条记录，不报错也不重复入库。
     */
    @PostMapping("/activities/{slug}/submissions")
    public ApiResponse.Envelope<Dtos.SubmissionResult> submit(@PathVariable String slug,
                                                              @RequestBody Dtos.SubmissionRequest request) {
        return ApiResponse.ok(submissionService.submit(slug, request));
    }
}
