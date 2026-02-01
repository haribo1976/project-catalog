# Sanitization Notes

This document describes what was removed from the public versions of the project catalog.

## Files

| File | Purpose |
|------|---------|
| `projects.yaml` | **PRIVATE** - Full catalog with all metadata |
| `projects.md` | **PRIVATE** - Full scorecard with GitHub links |
| `projects-public.yaml` | **PUBLIC** - Sanitized catalog |
| `projects-public.md` | **PUBLIC** - Sanitized overview |

## Data Removed from Public Versions

### Personal Identifiable Information (PII)
- [x] Full name removed from maintainer field
- [x] Local file system paths (revealed macOS username)

### Infrastructure Details
- [x] Deployed URLs (Azure Static Web Apps endpoints)
- [x] GitHub repository URLs (can be added back if repos are public)
- [x] Remote repository references

### Sensitive Project Information
- [x] `sec-audits` project removed (reveals security documentation exists)
- [x] FCA compliance references genericized
- [x] Specific compliance framework details reduced
- [x] `supersedes` relationships removed (reveals project history)
- [x] Archived projects section removed
- [x] Fork/reference repositories removed
- [x] Changelog with detailed actions removed

### Operational Details
- [x] Last commit dates removed
- [x] Stalled project status details removed
- [x] Detailed project counts and metrics reduced

## Recommendations Before Publishing

1. Review each project repository for sensitive data before making public
2. Ensure no API keys, credentials, or secrets in any committed code
3. Check `.env.example` files don't contain real values
4. Review deployment plans for infrastructure details
5. Consider making repositories private that handle:
   - Financial data (fin-budget-portal)
   - HR/employee data (hr-onboarding-portal)
   - Security configurations (sec-* projects)

## Re-adding GitHub URLs

If your repositories are already public, you can add URLs back to `projects-public.md`:

```yaml
remote: https://github.com/USERNAME/project-name
```

Replace `USERNAME` with your GitHub username.
