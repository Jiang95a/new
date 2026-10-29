# 端到端验收脚本：对着已经启动的 http://127.0.0.1:8080/api/v1 跑一遍主流程
# 用法：powershell -ExecutionPolicy Bypass -File e2e-test.ps1
$ErrorActionPreference = 'Continue'
$base = "http://127.0.0.1:8080/api/v1"
$pass = 0
$fail = 0

function Hit($method, $path, $body, $token) {
    $headers = @{}
    if ($token) { $headers['Authorization'] = "Bearer $token" }
    $params = @{
        Uri             = "$base$path"
        Method          = $method
        UseBasicParsing = $true
        TimeoutSec      = 40
        MaximumRedirection = 0
        Headers         = $headers
    }
    if ($null -ne $body) {
        $params['ContentType'] = 'application/json; charset=utf-8'
        $params['Body'] = [System.Text.Encoding]::UTF8.GetBytes(($body | ConvertTo-Json -Compress -Depth 20))
    }
    try {
        $resp = Invoke-WebRequest @params
        return @{ code = [int]$resp.StatusCode; body = $resp.Content }
    } catch {
        $r = $_.Exception.Response
        if ($r) {
            $sr = New-Object System.IO.StreamReader($r.GetResponseStream())
            return @{ code = [int]$r.StatusCode; body = $sr.ReadToEnd() }
        }
        return @{ code = 0; body = $_.Exception.Message }
    }
}

function Check($name, $got, $want) {
    if ($got -eq $want) {
        Write-Host ("  [PASS] {0}  -> {1}" -f $name, $got) -ForegroundColor Green
        $script:pass++
    } else {
        Write-Host ("  [FAIL] {0}  -> 期望 {1}，实际 {2}" -f $name, $want, $got) -ForegroundColor Red
        $script:fail++
    }
}

Write-Host "`n===== 1. 健康检查 =====" -ForegroundColor Cyan
$r = Hit 'GET' '/health' $null $null
Check 'GET /health' $r.code 200
Write-Host "  $($r.body)"
$r = Hit 'GET' '/ping' $null $null
Check 'GET /ping' $r.code 200

Write-Host "`n===== 2. 注册 / 登录 =====" -ForegroundColor Cyan
$email = "e2e$((Get-Random -Maximum 999999))@example.com"
$r = Hit 'POST' '/auth/register' @{ email = $email; password = 'Passw0rd!123'; displayName = '李同学' } $null
Check 'POST /auth/register' $r.code 200
$reg = $r.body | ConvertFrom-Json
$token = $reg.data.accessToken
$refresh = $reg.data.refreshToken
if ($token) { Write-Host "  token 长度 $($token.Length)，refresh 长度 $($refresh.Length)" }

$r = Hit 'POST' '/auth/register' @{ email = $email; password = 'Passw0rd!123'; displayName = '重复' } $null
Check '重复注册应 400' $r.code 400

$r = Hit 'POST' '/auth/login' @{ email = $email; password = 'Passw0rd!123' } $null
Check 'POST /auth/login' $r.code 200

$r = Hit 'POST' '/auth/login' @{ email = $email; password = 'wrong' } $null
Check '错误密码应 401' $r.code 401

$r = Hit 'GET' '/auth/me' $null $token
Check 'GET /auth/me（带 token）' $r.code 200
Write-Host "  $($r.body)"

$r = Hit 'GET' '/auth/me' $null $null
Check 'GET /auth/me（无 token）应 401' $r.code 401

$r = Hit 'POST' '/auth/refresh' @{ refreshToken = $refresh } $null
Check 'POST /auth/refresh' $r.code 200
$newToken = ($r.body | ConvertFrom-Json).data.accessToken

$r = Hit 'POST' '/auth/refresh' @{ refreshToken = $refresh } $null
Check '旧 refresh 应失效 401' $r.code 401

Write-Host "`n===== 3. 模板 =====" -ForegroundColor Cyan
$token = $newToken
$r = Hit 'GET' '/templates' $null $token
Check 'GET /templates' $r.code 200
$tpls = ($r.body | ConvertFrom-Json).data
Write-Host "  模板数量: $($tpls.Count)"
$tplId = $tpls[0].id

Write-Host "`n===== 4. 项目 CRUD =====" -ForegroundColor Cyan
$r = Hit 'POST' '/projects' @{ title = '社团招新 2026'; description = 'E2E 测试项目'; templateId = $tplId } $token
Check 'POST /projects' $r.code 200
$proj = ($r.body | ConvertFrom-Json).data
$pid2 = $proj.id
Write-Host "  projectId=$pid2 status=$($proj.status)"

$r = Hit 'GET' "/projects/$pid2" $null $token
Check 'GET /projects/{id}' $r.code 200

$r = Hit 'GET' '/projects?q=招新&page=1&pageSize=10' $null $token
Check 'GET /projects?q=招新' $r.code 200
Write-Host "  $($r.body)"

Write-Host "`n===== 5. 草稿乐观锁 =====" -ForegroundColor Cyan
$doc = @{
    title = '社团招新 2026'
    theme = @{ primary = '#3b82f6'; accent = '#f59e0b'; bg = '#ffffff'; text = '#111827'; radius = 12; fontScale = 1; spacing = 1; buttonStyle = 'solid'; font = 'sans' }
    pages = @(
        @{ id = 'p1'; name = '首页'; role = 'home'; bg = '#ffffff'; blocks = @(
                @{ id = 'b1'; type = 'banner'; props = @{ title = 'XX 社团招新'; subtitle = '欢迎加入' }; hidden = $false },
                @{ id = 'b2'; type = 'form'; props = @{ fields = @(
                            @{ id = 'f1'; label = '姓名'; type = 'text'; required = $true },
                            @{ id = 'f2'; label = '学号'; type = 'text'; required = $true }
                        ) }; hidden = $false }
            ) }
    )
}
$r = Hit 'PUT' "/projects/$pid2/draft" @{ document = $doc; baseRevision = 0 } $token
Check 'PUT /draft（baseRevision=0）' $r.code 200
$draft = ($r.body | ConvertFrom-Json).data
$rev = $draft.revision
Write-Host "  新 revision=$rev"

$r = Hit 'PUT' "/projects/$pid2/draft" @{ document = $doc; baseRevision = 0 } $token
Check 'PUT /draft（旧 baseRevision=0）应 409' $r.code 409

Write-Host "`n===== 6. 校验与发布 =====" -ForegroundColor Cyan
$badDoc = @{ title = '坏文档'; pages = 'not-an-array' }
$r = Hit 'PUT' "/projects/$pid2/draft" @{ document = $badDoc; baseRevision = $rev } $token
Check '非法 PageDocument 应 422' $r.code 422
Write-Host "  $($r.body)"

$slug = 'club-' + (Get-Random -Minimum 100000 -Maximum 999999)
$r = Hit 'POST' "/projects/$pid2/publish" @{ settings = @{}; slug = $slug } $token
Check 'POST /projects/{id}/publish' $r.code 200
Write-Host "  $($r.body)"
if ($r.code -ne 200) { $slug = $null }

if ($slug) {
    # 把同样的 slug 手动拨到另一个项目上，验证唯一约束翻译成 409 而不是 500
    $r = Hit 'POST' '/projects' @{ title = '撞车项目'; templateId = $tplId } $token
    $pid3 = ($r.body | ConvertFrom-Json).data.id
    $r = Hit 'PUT' "/projects/$pid3/draft" @{ baseRevision = 0; document = $doc } $token
    $r = Hit 'POST' "/projects/$pid3/publish" @{ settings = @{}; slug = $slug } $token
    Check '重复 slug 应 409' $r.code 409
}

Write-Host "`n===== 7. 公开页与提交 =====" -ForegroundColor Cyan
if ($slug) {
    $r = Hit 'GET' "/public/activities/$slug" $null $null
    Check 'GET /public/activities/{slug}（匿名）' $r.code 200
    $pub = ($r.body | ConvertFrom-Json).data
    Write-Host "  publicStatus=$($pub.publicStatus) title=$($pub.title)"
}

$r = Hit 'GET' '/public/activities/nonexistent-slug' $null $null
Check '不存在的 slug 应 404' $r.code 404

# 前端提交时 answers 的 key 是 "<blockId>:<fieldId>"（见 web/src/views/PublicActivityView.vue:65）
$ans = @{ 'b2:f1' = '张三'; 'b2:f2' = '2026001' }
$idem = 'idem-' + [guid]::NewGuid().ToString()
$firstId = $null
if ($slug) {
    $r = Hit 'POST' "/public/activities/$slug/submissions" @{ pageId = 'p1'; formComponentId = 'b2'; answers = $ans; idempotencyKey = $idem } $null
    Check 'POST 提交（首次）' $r.code 200
    $firstId = ($r.body | ConvertFrom-Json).data.submissionId
    Write-Host "  submissionId=$firstId"

    $r = Hit 'POST' "/public/activities/$slug/submissions" @{ pageId = 'p1'; formComponentId = 'b2'; answers = $ans; idempotencyKey = $idem } $null
    Check 'POST 提交（同 key 幂等）' $r.code 200
    $secondId = ($r.body | ConvertFrom-Json).data.submissionId
    if ($firstId -and $firstId -eq $secondId) {
        Write-Host "  [PASS] 幂等命中：两次返回同一 submissionId" -ForegroundColor Green
        $pass++
    } else {
        Write-Host "  [FAIL] 幂等失效：$firstId vs $secondId" -ForegroundColor Red
        $fail++
    }

    $r = Hit 'POST' "/public/activities/$slug/submissions" @{ pageId = 'p1'; formComponentId = 'b2'; answers = @{ 'b2:f1' = '李四' }; idempotencyKey = ('idem-' + [guid]::NewGuid().ToString()) } $null
    Check '缺少必填项应 422' $r.code 422
    Write-Host "  $($r.body)"
}

Write-Host "`n===== 8. 提交列表与统计 =====" -ForegroundColor Cyan
$r = Hit 'GET' "/projects/$pid2/submissions?page=1&pageSize=10" $null $token
Check 'GET 提交列表' $r.code 200
Write-Host "  $($r.body.Substring(0, [Math]::Min(300, $r.body.Length)))"

$r = Hit 'GET' "/projects/$pid2/analytics/summary" $null $token
Check 'GET analytics/summary' $r.code 200
Write-Host "  $($r.body)"

Write-Host "`n===== 9. 导出 =====" -ForegroundColor Cyan
$r = Hit 'POST' "/projects/$pid2/exports" @{} $token
Check 'POST exports' $r.code 200
$exp = ($r.body | ConvertFrom-Json).data
Write-Host "  $($r.body)"

$r = Hit 'GET' "/exports/$($exp.id)/download" $null $token
Check 'GET 导出下载' $r.code 200
Write-Host "  CSV 前 120 字符: $($r.body.Substring(0,[Math]::Min(120,$r.body.Length)))"

Write-Host "`n===== 10. 越权检查 =====" -ForegroundColor Cyan
$email2 = "other$((Get-Random -Maximum 999999))@example.com"
$r = Hit 'POST' '/auth/register' @{ email = $email2; password = 'Passw0rd!123'; displayName = '王同学' } $null
$token2 = ($r.body | ConvertFrom-Json).data.accessToken
$r = Hit 'GET' "/projects/$pid2" $null $token2
Check '别人读我的项目应 403/404' $r.code 403

Write-Host "`n===== 11. AI 降级 =====" -ForegroundColor Cyan
$r = Hit 'POST' '/ai/chat' @{ message = '你好' } $token
Check 'POST /ai/chat（agent 未启动应 503）' $r.code 503
Write-Host "  $($r.body)"

$r = Hit 'GET' '/ai/agent/health' $null $token
Check 'GET /ai/agent/health' $r.code 200
Write-Host "  $($r.body)"

Write-Host "`n===== 12. 登出 =====" -ForegroundColor Cyan
$r = Hit 'POST' '/auth/logout' @{} $token
Check 'POST /auth/logout' $r.code 200
$r = Hit 'GET' '/auth/me' $null $token
Check '登出后 /auth/me 应 401' $r.code 401

Write-Host ("`n================ 汇总：PASS {0} / FAIL {1} ================" -f $pass, $fail) -ForegroundColor Yellow
if ($fail -eq 0) { Write-Host "全部通过" -ForegroundColor Green } else { Write-Host "有失败项，见上面 [FAIL]" -ForegroundColor Red }
