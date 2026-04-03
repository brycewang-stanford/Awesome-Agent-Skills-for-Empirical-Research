# Block accidental edits to protected files
# CUSTOMIZE: Add patterns to $ProtectedPatterns for files you want to protect
$Input = $input | Out-String
$JsonInput = $Input | ConvertFrom-Json
$Tool = $JsonInput.tool_name
$File = ""

if ($Tool -eq "Edit" -or $Tool -eq "Write") {
    $File = $JsonInput.tool_input.file_path
}

# No file path = not a file operation, allow
if (-not $File) {
    exit 0
}

# CUSTOMIZE: Add patterns for files you want to protect
$ProtectedPatterns = @(
    "settings.json"
)

$Basename = Split-Path $File -Leaf
foreach ($Pattern in $ProtectedPatterns) {
    if ($Basename -eq $Pattern) {
        [Console]::Error.WriteLine("Protected file: $Basename. Edit manually or remove protection in .claude/hooks/protect-files.ps1")
        exit 2
    }
}

exit 0
