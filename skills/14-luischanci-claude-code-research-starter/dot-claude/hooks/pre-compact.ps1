# Save a context snapshot to the session log before compaction
$Input = $input | Out-String
try {
    $JsonInput = $Input | ConvertFrom-Json
    $Trigger = if ($JsonInput.trigger) { $JsonInput.trigger } else { "unknown" }
} catch {
    $Trigger = "unknown"
}

$LogDir = Join-Path $env:CLAUDE_PROJECT_DIR "quality_reports\session_logs"
$LatestLog = Get-ChildItem -Path $LogDir -Filter "*.md" -ErrorAction SilentlyContinue |
    Sort-Object LastWriteTime -Descending |
    Select-Object -First 1

if ($LatestLog) {
    $Timestamp = Get-Date -Format "HH:mm"
    $Append = @"

---
**Context compaction ($Trigger) at $Timestamp**
Check git log and quality_reports/plans/ for current state.
"@
    Add-Content -Path $LatestLog.FullName -Value $Append
}

exit 0
