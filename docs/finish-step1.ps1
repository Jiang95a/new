$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
Set-Location $repoRoot

function Invoke-Git {
    param(
        [Parameter(ValueFromRemainingArguments = $true)]
        [string[]] $GitArgs
    )

    & git @GitArgs
    if ($LASTEXITCODE -ne 0) {
        throw "Git 命令执行失败: git $($GitArgs -join ' ')"
    }
}

Write-Host "仓库目录: $repoRoot" -ForegroundColor Cyan

$paths = @(
    ".editorconfig",
    ".prettierignore",
    ".prettierrc.json",
    ".vscode",
    ".gitignore",
    "README.md",
    "docs",
    "web",
    "scripts"
)

foreach ($path in $paths) {
    if (Test-Path -LiteralPath $path) {
        Invoke-Git add -- $path
    }
}

& git diff --cached --quiet
if ($LASTEXITCODE -eq 0) {
    Write-Host "没有新的暂存内容，跳过程序提交。" -ForegroundColor Yellow
} else {
    Invoke-Git commit -m "feat(前端): 迁移至 Vue 并实现多页面编辑预览"
}

Write-Host "拉取团队最新 main..." -ForegroundColor Cyan
Invoke-Git pull --rebase origin main

Write-Host "推送到 origin/main..." -ForegroundColor Cyan
Invoke-Git push origin main

Write-Host "前端改动提交并推送完成。" -ForegroundColor Green

