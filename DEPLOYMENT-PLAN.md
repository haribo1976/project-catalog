# Project Catalog - Deployment Plan

**Version:** 1.0
**Last Updated:** 1 February 2026
**Author:** Richard Stainforth

## Overview

Central source of truth for all projects in the portfolio - maintains machine-readable catalog, enforces naming conventions, and tracks compliance status.

## Current State

| Component | Status | Notes |
|-----------|--------|-------|
| Catalog YAML | ✅ Complete | projects.yaml |
| Documentation | ✅ Complete | projects.md |
| Release Scripts | ✅ Complete | Shell scripts |
| Web Explorer | ❌ Not built | Future enhancement |
| CI/CD Integration | ❌ Not implemented | Future enhancement |

**Estimated Monthly Cost:** £0

## Architecture

### Current (Repository)
```
project-catalog/
├── projects.yaml          # Machine-readable catalog
├── projects.md            # Human-readable documentation
├── schemas/
│   └── project.schema.json
├── scripts/
│   ├── validate-catalog.sh
│   ├── generate-docs.sh
│   └── release.sh
└── CLAUDE.md              # AI instructions
```

### Future (Web Portal)
```
┌─────────────────────────────────────────────────────────────────┐
│                    Azure Static Web App                          │
│                    (Project Explorer)                            │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                    GitHub API                                    │
│               (Repository Metadata)                              │
└─────────────────────────────────────────────────────────────────┘
```

## Naming Convention

```
{domain}-{product}-{component?}-{qualifier?}

Domains:
- azure    (Azure infrastructure)
- m365     (Microsoft 365)
- sec      (Security & compliance)
- grc      (Governance, risk, compliance)
- ops      (Operations)
- fin      (Finance)
- hr       (Human resources)
- lib      (Libraries)
- personal (Personal projects)
```

## Deployment Phases

### Phase 1: Validation Automation (Day 1)

#### 1.1 GitHub Action for Catalog Validation
```yaml
# .github/workflows/validate.yml
name: Validate Catalog
on:
  push:
    paths:
      - 'projects.yaml'
  pull_request:
    paths:
      - 'projects.yaml'

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Validate YAML
        run: |
          pip install yamllint pyyaml jsonschema
          yamllint projects.yaml
          python scripts/validate-schema.py

      - name: Check naming conventions
        run: ./scripts/validate-names.sh
```

### Phase 2: Auto-Documentation (Day 1)

#### 2.1 Generate Documentation
```yaml
# .github/workflows/docs.yml
name: Update Documentation
on:
  push:
    paths:
      - 'projects.yaml'

jobs:
  generate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Generate projects.md
        run: ./scripts/generate-docs.sh

      - name: Commit changes
        run: |
          git config user.name "GitHub Actions"
          git config user.email "actions@github.com"
          git add projects.md
          git commit -m "docs: auto-update from catalog" || exit 0
          git push
```

### Phase 3: Web Explorer (Future - Day 2-3)

#### 3.1 Static Site Generator
```bash
# Using Eleventy
npm init -y
npm install @11ty/eleventy
```

#### 3.2 Project List Template
```njk
<!-- src/index.njk -->
{% for project in projects %}
<article class="project-card">
  <h2>{{ project.name }}</h2>
  <p>{{ project.description }}</p>
  <span class="badge">{{ project.status }}</span>
  <a href="{{ project.repo }}">View Repository</a>
</article>
{% endfor %}
```

### Phase 4: CI/CD Integration (Future)

#### 4.1 Catalog Refresh on Deploy
```yaml
# In each project's workflow
- name: Update catalog
  run: |
    curl -X POST \
      -H "Authorization: token ${{ secrets.CATALOG_TOKEN }}" \
      https://api.github.com/repos/haribo1976/project-catalog/dispatches \
      -d '{"event_type":"project_deployed","client_payload":{"project":"${{ github.repository }}"}}'
```

#### 4.2 Status Badges
```markdown
![Status](https://img.shields.io/badge/status-active-green)
![Compliance](https://img.shields.io/badge/compliance-passing-green)
```

## Project Schema

```yaml
# projects.yaml structure
projects:
  - name: azure-iac-portal
    domain: azure
    product: iac-portal
    description: Infrastructure as Code Management Platform
    status: development
    tech_stack:
      - React
      - TypeScript
      - Azure Functions
    repository: https://github.com/haribo1976/azure-iac-portal
    deployment:
      type: azure-static-web-app
      url: https://iac-portal.example.com
    quality:
      ci_cd: true
      tests: partial
      documentation: complete
    compliance:
      security_scan: passing
      dependency_audit: passing
```

## Production Checklist

- [x] Catalog YAML complete
- [x] Documentation generated
- [x] Release scripts ready
- [ ] GitHub Actions validation
- [ ] Auto-documentation workflow
- [ ] Web explorer (optional)
- [ ] Status badges
- [ ] CI/CD integration
- [ ] Dependency tracking

## Cost Breakdown

| Resource | SKU | Est. Monthly Cost |
|----------|-----|-------------------|
| GitHub Repository | Free | £0 |
| GitHub Actions | Free tier | £0 |
| Static Web App (optional) | Free | £0 |
| **Total** | | **£0** |

## Commands Reference

```bash
# Validate catalog
./scripts/validate-catalog.sh

# Generate documentation
./scripts/generate-docs.sh

# Create release
./scripts/release.sh v0.2.0

# List all projects
yq '.projects[].name' projects.yaml
```

## Revision History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-02-01 | Initial deployment plan |
