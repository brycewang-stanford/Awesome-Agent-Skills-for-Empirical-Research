# Windows toast notification when Claude needs attention
$Input = $input | Out-String
try {
    $JsonInput = $Input | ConvertFrom-Json
    $Message = if ($JsonInput.message) { $JsonInput.message } else { "Claude needs attention" }
    $Title = if ($JsonInput.title) { $JsonInput.title } else { "Claude Code" }
} catch {
    $Message = "Claude needs attention"
    $Title = "Claude Code"
}

try {
    [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] | Out-Null
    $Template = [Windows.UI.Notifications.ToastNotificationManager]::GetTemplateContent([Windows.UI.Notifications.ToastTemplateType]::ToastText02)
    $TextNodes = $Template.GetElementsByTagName("text")
    $TextNodes.Item(0).AppendChild($Template.CreateTextNode($Title)) | Out-Null
    $TextNodes.Item(1).AppendChild($Template.CreateTextNode($Message)) | Out-Null
    $Toast = [Windows.UI.Notifications.ToastNotification]::new($Template)
    [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier("Claude Code").Show($Toast)
} catch {
    # Fallback: silent -- notification is best-effort
}

exit 0
