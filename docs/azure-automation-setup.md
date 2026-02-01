# Azure Automation - Nightly Shutdown

This document describes the nightly shutdown automation configured for the Azure subscription.

## Overview

The automation shuts down compute resources at **10 PM UK time** every night to reduce costs.

## Resources

| Resource | Resource Group | Type |
|----------|----------------|------|
| `m365-maturity-automation` | rg-m365-maturity-portal | Automation Account |
| `Stop-NightlyResources` | - | PowerShell Runbook |
| `NightlyShutdown-10PM-UK` | - | Daily Schedule |
| `send-shutdown-email` | rg-m365-maturity-portal | Logic App (pending email config) |

## What Gets Shut Down

The runbook stops:
- **Web Apps** (App Service)
- **Function Apps**

## Excluded Resources

The following are excluded from nightly shutdown:

| Resource Group | Reason |
|----------------|--------|
| `rg-portfolio-prod-uks` | Personal brochure website |
| `rg-pensham-daughters` | Personal project |

**Note:** Static Web Apps are serverless and don't need to be stopped - they only incur costs per request.

## Schedule

- **Time:** 10:00 PM UK time (adjusts for BST/GMT)
- **Frequency:** Daily
- **Next Run:** Check Azure Portal for scheduled run time

## Email Notifications

### Current Status
The automation is configured to send email reports but requires completing the Office 365 connection setup.

### To Complete Email Setup

1. Go to the Azure Portal
2. Navigate to: **Resource Groups** > **rg-m365-maturity-portal** > **send-shutdown-email** (Logic App)
3. Click **Logic App Designer**
4. Add an action: **Office 365 Outlook - Send an email (V2)**
5. Sign in with your Office 365 account when prompted
6. Configure the email action:
   - **To:** `@triggerBody()?['recipient']`
   - **Subject:** `@triggerBody()?['subject']`
   - **Body:** `@triggerBody()?['htmlBody']`
   - Set **Is HTML** to **Yes**
7. Save the Logic App

### Alternative: Use Action Group Notifications

The existing action group `m365-maturity-portal-alerts` is configured to send basic email notifications to `richard@52westgate.co.uk` when automation jobs complete.

## Manual Run

To run the shutdown manually:

```bash
az automation runbook start \
  --automation-account-name "m365-maturity-automation" \
  --resource-group "rg-m365-maturity-portal" \
  --name "Stop-NightlyResources"
```

Or via the Azure Portal:
1. Navigate to the Automation Account
2. Select **Runbooks** > **Stop-NightlyResources**
3. Click **Start**

## Viewing Job Output

To view the output of previous runs:

1. Go to **Automation Account** > **Jobs**
2. Select a completed job
3. Click **Output** to see the full report

## Modifying Exclusions

To add or remove exclusions, edit the runbook and update the `$ExcludedResourceGroups` array:

```powershell
$ExcludedResourceGroups = @(
    "rg-portfolio-prod-uks",      # Personal brochure
    "rg-pensham-daughters"         # Personal project
    # Add more resource groups here
)
```

Then re-publish the runbook.

## Costs

| Resource | Estimated Cost |
|----------|----------------|
| Automation Account | Free (500 minutes/month included) |
| Logic App | Free (up to 4,000 actions/month) |
| Stopped Web/Function Apps | No compute charges while stopped |

## Troubleshooting

### Runbook Fails to Connect
- Ensure the managed identity has **Contributor** role on the subscription
- Check that the automation account's system-assigned identity is enabled

### Resources Not Stopping
- Verify the resource is a Web App or Function App (not Static Web App)
- Check the resource group is not in the exclusion list
- Review the job output for specific errors

### Email Not Sending
- Complete the Office 365 connection setup in the Logic App
- Check the Logic App run history for errors
- Verify the webhook URL is correct in the runbook

---

*Created: 2026-02-01*
*Automation Account: m365-maturity-automation*
