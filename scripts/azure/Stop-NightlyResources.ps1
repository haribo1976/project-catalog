<#
.SYNOPSIS
    Nightly shutdown of Azure compute resources with email reporting.

.DESCRIPTION
    This runbook stops all Web Apps and Function Apps in the subscription
    at 10 PM nightly and sends a status report via email.

    Excludes:
    - Personal projects (brochure, pensham-daughters)
    - Static Web Apps (serverless, no shutdown needed)

.NOTES
    Author: Azure Automation
    Created: 2026-02-01
    Runs using System Assigned Managed Identity
#>

param(
    [Parameter(Mandatory = $false)]
    [string]$EmailRecipient = "richard@52westgate.co.uk",

    [Parameter(Mandatory = $false)]
    [string]$SubscriptionId = "e42e3b6b-42f4-49e1-8bbf-9ef13f4d90fa",

    [Parameter(Mandatory = $false)]
    [string]$LogicAppWebhookUrl = "https://prod-05.northeurope.logic.azure.com:443/workflows/e6a3cde9a827414a91725b6c3c7bc821/triggers/manual/paths/invoke?api-version=2016-06-01&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=zbsAvikJ8nDDTp6MWiebuZ_9jdQ85GwNhW0qO0z96_w"
)

# Resource groups to exclude from shutdown (personal projects)
$ExcludedResourceGroups = @(
    "rg-portfolio-prod-uks",      # Personal brochure
    "rg-pensham-daughters"         # Personal pensham-daughters site
)

# Disable verbose output for cleaner logs
$VerbosePreference = "SilentlyContinue"

Write-Output "========================================"
Write-Output "Nightly Resource Shutdown - $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') UTC"
Write-Output "========================================"

# Connect using Managed Identity
try {
    Connect-AzAccount -Identity -SubscriptionId $SubscriptionId | Out-Null
    Write-Output "Connected to Azure using Managed Identity"
}
catch {
    Write-Error "Failed to connect to Azure: $_"
    throw
}

# Initialize report
$report = @{
    Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss UTC"
    WebApps = @()
    FunctionApps = @()
    Errors = @()
    TotalStopped = 0
    TotalFailed = 0
}

# Stop Web Apps
Write-Output "`n--- Stopping Web Apps ---"
$webApps = Get-AzWebApp

foreach ($app in $webApps) {
    # Skip excluded resource groups
    if ($ExcludedResourceGroups -contains $app.ResourceGroup) {
        Write-Output "Excluded (personal project): $($app.Name) in $($app.ResourceGroup)"
        continue
    }

    $appInfo = @{
        Name = $app.Name
        ResourceGroup = $app.ResourceGroup
        PreviousState = $app.State
        Action = ""
        Result = ""
    }

    if ($app.State -eq "Running") {
        try {
            Write-Output "Stopping: $($app.Name) in $($app.ResourceGroup)"
            Stop-AzWebApp -Name $app.Name -ResourceGroupName $app.ResourceGroup | Out-Null
            $appInfo.Action = "Stopped"
            $appInfo.Result = "Success"
            $report.TotalStopped++
        }
        catch {
            $appInfo.Action = "Stop Failed"
            $appInfo.Result = $_.Exception.Message
            $report.Errors += "Web App $($app.Name): $($_.Exception.Message)"
            $report.TotalFailed++
        }
    }
    else {
        $appInfo.Action = "Skipped"
        $appInfo.Result = "Already stopped"
        Write-Output "Skipped (already stopped): $($app.Name)"
    }

    $report.WebApps += $appInfo
}

# Stop Function Apps
Write-Output "`n--- Stopping Function Apps ---"
$functionApps = Get-AzFunctionApp

foreach ($app in $functionApps) {
    # Skip excluded resource groups
    if ($ExcludedResourceGroups -contains $app.ResourceGroup) {
        Write-Output "Excluded (personal project): $($app.Name) in $($app.ResourceGroup)"
        continue
    }

    $appInfo = @{
        Name = $app.Name
        ResourceGroup = $app.ResourceGroup
        PreviousState = $app.Status
        Action = ""
        Result = ""
    }

    if ($app.Status -eq "Running") {
        try {
            Write-Output "Stopping: $($app.Name) in $($app.ResourceGroup)"
            Stop-AzFunctionApp -Name $app.Name -ResourceGroupName $app.ResourceGroup -Force | Out-Null
            $appInfo.Action = "Stopped"
            $appInfo.Result = "Success"
            $report.TotalStopped++
        }
        catch {
            $appInfo.Action = "Stop Failed"
            $appInfo.Result = $_.Exception.Message
            $report.Errors += "Function App $($app.Name): $($_.Exception.Message)"
            $report.TotalFailed++
        }
    }
    else {
        $appInfo.Action = "Skipped"
        $appInfo.Result = "Already stopped"
        Write-Output "Skipped (already stopped): $($app.Name)"
    }

    $report.FunctionApps += $appInfo
}

# Generate HTML email body
$htmlBody = @"
<!DOCTYPE html>
<html>
<head>
    <style>
        body { font-family: 'Segoe UI', Arial, sans-serif; margin: 20px; background-color: #f5f5f5; }
        .container { max-width: 800px; margin: 0 auto; background: white; padding: 30px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        h1 { color: #0078d4; border-bottom: 2px solid #0078d4; padding-bottom: 10px; }
        h2 { color: #333; margin-top: 25px; }
        .summary { background: #e7f3ff; padding: 15px; border-radius: 5px; margin: 20px 0; }
        .summary-item { display: inline-block; margin-right: 30px; }
        .summary-value { font-size: 24px; font-weight: bold; color: #0078d4; }
        table { width: 100%; border-collapse: collapse; margin: 15px 0; }
        th { background: #0078d4; color: white; padding: 12px; text-align: left; }
        td { padding: 10px; border-bottom: 1px solid #ddd; }
        tr:hover { background: #f9f9f9; }
        .success { color: #107c10; font-weight: bold; }
        .failed { color: #d13438; font-weight: bold; }
        .skipped { color: #8a8886; }
        .errors { background: #fde7e9; padding: 15px; border-radius: 5px; margin: 20px 0; }
        .footer { margin-top: 30px; padding-top: 20px; border-top: 1px solid #ddd; color: #666; font-size: 12px; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🌙 Nightly Shutdown Report</h1>
        <p><strong>Timestamp:</strong> $($report.Timestamp)</p>

        <div class="summary">
            <div class="summary-item">
                <div class="summary-value">$($report.TotalStopped)</div>
                <div>Resources Stopped</div>
            </div>
            <div class="summary-item">
                <div class="summary-value">$($report.TotalFailed)</div>
                <div>Failed</div>
            </div>
            <div class="summary-item">
                <div class="summary-value">$($report.WebApps.Count + $report.FunctionApps.Count)</div>
                <div>Total Processed</div>
            </div>
        </div>
"@

# Add Web Apps table
if ($report.WebApps.Count -gt 0) {
    $htmlBody += @"
        <h2>Web Apps</h2>
        <table>
            <tr>
                <th>Name</th>
                <th>Resource Group</th>
                <th>Previous State</th>
                <th>Action</th>
                <th>Result</th>
            </tr>
"@
    foreach ($app in $report.WebApps) {
        $resultClass = switch ($app.Result) {
            "Success" { "success" }
            "Already stopped" { "skipped" }
            default { "failed" }
        }
        $htmlBody += @"
            <tr>
                <td>$($app.Name)</td>
                <td>$($app.ResourceGroup)</td>
                <td>$($app.PreviousState)</td>
                <td>$($app.Action)</td>
                <td class="$resultClass">$($app.Result)</td>
            </tr>
"@
    }
    $htmlBody += "</table>"
}

# Add Function Apps table
if ($report.FunctionApps.Count -gt 0) {
    $htmlBody += @"
        <h2>Function Apps</h2>
        <table>
            <tr>
                <th>Name</th>
                <th>Resource Group</th>
                <th>Previous State</th>
                <th>Action</th>
                <th>Result</th>
            </tr>
"@
    foreach ($app in $report.FunctionApps) {
        $resultClass = switch ($app.Result) {
            "Success" { "success" }
            "Already stopped" { "skipped" }
            default { "failed" }
        }
        $htmlBody += @"
            <tr>
                <td>$($app.Name)</td>
                <td>$($app.ResourceGroup)</td>
                <td>$($app.PreviousState)</td>
                <td>$($app.Action)</td>
                <td class="$resultClass">$($app.Result)</td>
            </tr>
"@
    }
    $htmlBody += "</table>"
}

# Add errors section if any
if ($report.Errors.Count -gt 0) {
    $htmlBody += @"
        <div class="errors">
            <h2>⚠️ Errors</h2>
            <ul>
"@
    foreach ($error in $report.Errors) {
        $htmlBody += "<li>$error</li>"
    }
    $htmlBody += "</ul></div>"
}

$htmlBody += @"
        <div class="footer">
            <p>This report was generated automatically by Azure Automation.</p>
            <p>Subscription: $SubscriptionId</p>
        </div>
    </div>
</body>
</html>
"@

# Output report summary
Write-Output "`n========================================"
Write-Output "SHUTDOWN SUMMARY"
Write-Output "========================================"
Write-Output "Total Stopped: $($report.TotalStopped)"
Write-Output "Total Failed: $($report.TotalFailed)"
Write-Output "Total Processed: $($report.WebApps.Count + $report.FunctionApps.Count)"

if ($report.Errors.Count -gt 0) {
    Write-Output "`nErrors:"
    foreach ($err in $report.Errors) {
        Write-Output "  - $err"
    }
}

# Store HTML body in automation variable for Logic App to pick up
# The Logic App will handle sending the email
$reportJson = $report | ConvertTo-Json -Depth 10
Write-Output "`n--- Report JSON ---"
Write-Output $reportJson

# Send email report via webhook if configured
if ($LogicAppWebhookUrl -and $LogicAppWebhookUrl -ne "") {
    Write-Output "`n--- Sending Email Report ---"
    try {
        $emailPayload = @{
            recipient = $EmailRecipient
            subject = "Nightly Shutdown Report - $($report.Timestamp)"
            htmlBody = $htmlBody
            summary = @{
                totalStopped = $report.TotalStopped
                totalFailed = $report.TotalFailed
                timestamp = $report.Timestamp
            }
        }

        # Get SAS token from Logic App URL and make request
        $response = Invoke-RestMethod -Uri $LogicAppWebhookUrl -Method POST -Body ($emailPayload | ConvertTo-Json -Depth 5) -ContentType "application/json"
        Write-Output "Email report sent successfully"
    }
    catch {
        Write-Warning "Failed to send email via webhook: $($_.Exception.Message)"
        $report.Errors += "Email delivery failed: $($_.Exception.Message)"
    }
}
else {
    Write-Output "`n--- EMAIL_BODY_START ---"
    Write-Output $htmlBody
    Write-Output "--- EMAIL_BODY_END ---"
}

Write-Output "`nNightly shutdown complete at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') UTC"
