# 启动脚本：.\start.ps1
# 如果报"禁止运行脚本"，先执行：
#   Set-ExecutionPolicy -Scope CurrentUser RemoteSigned

$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

$py = Join-Path $PSScriptRoot ".venv\Scripts\python.exe"
if (-not (Test-Path $py)) {
    Write-Host "找不到虚拟环境：$py" -ForegroundColor Red
    Write-Host "请先执行：py -3.12 -m venv .venv" -ForegroundColor Yellow
    exit 1
}

Write-Host "启动中... 文档地址 http://127.0.0.1:8000/docs" -ForegroundColor Cyan
& $py -m uvicorn app.main:app --reload --host 127.0.0.1 --port 8000
