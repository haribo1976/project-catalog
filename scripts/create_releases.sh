#!/bin/bash
# create_releases.sh
# Creates releases for all projects in the portfolio
# Usage: ./scripts/create_releases.sh --version v0.2.0-alpha [--stage alpha|beta|rc|stable]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GITHUB_USER="haribo1976"

# Default values
VERSION=""
STAGE="alpha"
DRY_RUN=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --version)
            VERSION="$2"
            shift 2
            ;;
        --stage)
            STAGE="$2"
            shift 2
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --help)
            echo "Usage: $0 --version VERSION [--stage STAGE] [--dry-run]"
            echo ""
            echo "Options:"
            echo "  --version   Version tag (e.g., v0.2.0-alpha)"
            echo "  --stage     Release stage: alpha, beta, rc, stable (default: alpha)"
            echo "  --dry-run   Show what would be done without creating releases"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Validate version
if [[ -z "$VERSION" ]]; then
    echo "Error: --version is required"
    echo "Usage: $0 --version VERSION [--stage STAGE]"
    exit 1
fi

# Validate version format
if ! echo "$VERSION" | grep -qE '^v[0-9]+\.[0-9]+\.[0-9]+(-[a-z]+(\.[0-9]+)?)?$'; then
    echo "Error: Invalid version format. Use semantic versioning (e.g., v0.1.0-alpha)"
    exit 1
fi

# Determine if prerelease
IS_PRERELEASE=true
case $STAGE in
    stable)
        IS_PRERELEASE=false
        ;;
    alpha|beta|rc)
        IS_PRERELEASE=true
        ;;
    *)
        echo "Error: Invalid stage. Use: alpha, beta, rc, or stable"
        exit 1
        ;;
esac

# Project list with display names
projects=(
    "azure-iac-portal:Azure IaC Portal"
    "azure-waf-monitor:Azure WAF Monitor"
    "doc-intake-classifier:Document Intake Classifier"
    "fca-file-checker:FCA File Checker"
    "fin-budget-portal:Finance Budget Portal"
    "grc-isms-portal:ISMS Portal"
    "grc-template-library:GRC Template Library"
    "hr-onboarding-portal:HR Onboarding Portal"
    "lib-brand-design-system:Brand Design System"
    "m365-admin-hub:M365 Admin Hub"
    "m365-azure-maturity-toolbox:M365 Azure Maturity Toolbox"
    "m365-governance-assessment:M365 Governance Assessment"
    "m365-migration-portal:M365 Migration Portal"
    "ops-diagnostic-portal:IT Ops Diagnostic Portal"
    "ops-serviceflow-mvp:ServiceFlow MVP"
    "ops-supplier-portal:Supplier Portal"
    "personal-brochure:Personal Brochure"
    "personal-pensham-daughters:Pensham & Daughters"
    "project-catalog:Project Catalog"
    "sec-audits:Security Audits"
    "sec-cyberessentials-monitor:Cyber Essentials Monitor"
    "sec-servicetrust-portal:Service Trust Portal"
    "sec-supplier-portal:Supplier Security Portal"
)

echo "=== Bulk Release Creation ==="
echo "Version: $VERSION"
echo "Stage: $STAGE"
echo "Pre-release: $IS_PRERELEASE"
echo "Dry run: $DRY_RUN"
echo ""

# Build release notes
STAGE_UPPER=$(echo "$STAGE" | tr '[:lower:]' '[:upper:]')
PROD_READY="No"
[[ "$STAGE" == "stable" ]] && PROD_READY="Yes"

release_notes="## Release $VERSION

### Status
- **Version**: ${VERSION#v}
- **Stage**: $STAGE_UPPER
- **Production Ready**: $PROD_READY

### What's Included
- Latest codebase updates
- Bug fixes and improvements

### Notes
See repository README for usage instructions."

success_count=0
fail_count=0
skipped_count=0

for item in "${projects[@]}"; do
    repo="${item%%:*}"
    display_name="${item#*:}"
    title="$display_name $VERSION"

    echo "Processing $repo..."

    # Check if archived
    is_archived=$(gh repo view "$GITHUB_USER/$repo" --json isArchived -q '.isArchived' 2>/dev/null || echo "false")

    # Check if release already exists
    existing=$(gh release view "$VERSION" --repo "$GITHUB_USER/$repo" 2>/dev/null && echo "exists" || echo "")

    if [[ -n "$existing" ]]; then
        echo "  ⏭️  Skipped: Release $VERSION already exists"
        ((skipped_count++))
        continue
    fi

    if [[ "$DRY_RUN" == "true" ]]; then
        echo "  [DRY RUN] Would create: $title"
        ((success_count++))
        continue
    fi

    # Unarchive if needed
    if [[ "$is_archived" == "true" ]]; then
        echo "  (unarchiving...)"
        gh repo unarchive "$GITHUB_USER/$repo" --yes 2>/dev/null
    fi

    # Build gh release command
    prerelease_flag=""
    [[ "$IS_PRERELEASE" == "true" ]] && prerelease_flag="--prerelease"

    if gh release create "$VERSION" \
        --repo "$GITHUB_USER/$repo" \
        --title "$title" \
        --notes "$release_notes" \
        $prerelease_flag 2>&1; then
        echo "  ✅ Created: $title"
        ((success_count++))
    else
        echo "  ❌ Failed"
        ((fail_count++))
    fi

    # Re-archive if it was archived
    if [[ "$is_archived" == "true" ]]; then
        echo "  (re-archiving...)"
        gh repo archive "$GITHUB_USER/$repo" --yes 2>/dev/null
    fi
done

echo ""
echo "=== Summary ==="
echo "Successful: $success_count"
echo "Failed: $fail_count"
echo "Skipped: $skipped_count"
