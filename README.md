# Project Catalog

Central source of truth for all projects in the haribo1976 portfolio. This repository maintains a machine-readable catalog of all projects, their metadata, and compliance status.

## Purpose

- **Discoverability**: Quickly find any project by category, technology, or purpose
- **Consistency**: Enforce naming conventions and documentation standards
- **Compliance**: Track which projects have proper CI, tests, and documentation
- **Maintenance**: Identify stale, archived, or deprecated projects

## Taxonomy

Projects are organised by domain prefix:

| Prefix | Domain | Description |
|--------|--------|-------------|
| `m365-` | Microsoft 365 | M365 administration, governance, and migration tools |
| `azure-` | Azure | Azure infrastructure, monitoring, and management |
| `grc-` | GRC | Governance, Risk, and Compliance tools |
| `sec-` | Security | Security auditing, monitoring, and compliance |
| `ops-` | Operations | IT operations and service management |
| `fin-` | Finance | Financial and budget management |
| `hr-` | Human Resources | HR, onboarding, and people management |
| `doc-` | Documents | Document processing and classification |
| `lib-` | Libraries | Reusable libraries and design systems |
| `personal-` | Personal | Personal and portfolio projects |
| `fca-` | FCA | Financial Conduct Authority related tools |

## Naming Convention

```
<domain>-<product>[-<component>][-<qualifier>]
```

### Rules

1. **All lowercase** with **kebab-case**
2. **No spaces or underscores**
3. Standard **component suffixes**:
   - `-portal` = Web application with dashboard/UI
   - `-hub` = Central management interface
   - `-api` = Backend API service
   - `-cli` = Command-line tool
   - `-lib` = Library/SDK
   - `-toolbox` = Collection of related tools
   - `-monitor` = Monitoring/alerting tool
   - `-checker` = Validation/checking tool
4. Optional **qualifier suffixes**:
   - `-mvp` = Minimum viable product/prototype
   - `-poc` = Proof of concept
   - `-v2` = Major version indicator

### Examples

| Name | Breakdown |
|------|-----------|
| `m365-admin-hub` | m365 (domain) + admin (product) + hub (component) |
| `sec-cyberessentials-monitor` | sec (domain) + cyberessentials (product) + monitor (component) |
| `ops-serviceflow-mvp` | ops (domain) + serviceflow (product) + mvp (qualifier) |

## Repository Structure

```
project-catalog/
├── README.md                    # This file
├── catalog/
│   ├── projects.yaml            # Machine-readable project catalog
│   └── projects.md              # Human-readable project listing
└── scripts/
    └── refresh_catalog.sh       # Script to update catalog from local repos
```

## Usage

### View the Catalog

See [catalog/projects.md](catalog/projects.md) for a human-readable listing.

### Refresh the Catalog

```bash
./scripts/refresh_catalog.sh
```

This will:
1. Scan the projects directory
2. Update `catalog/projects.yaml` with current metadata
3. Regenerate `catalog/projects.md`
4. Flag any naming convention violations

### Adding a New Project

1. Create repo following the naming convention
2. Run `./scripts/refresh_catalog.sh` to add it to the catalog
3. Commit and push the updated catalog

## Project Scorecard

Each project is evaluated on DORA-aligned quality indicators:

| Indicator | Description |
|-----------|-------------|
| CI Present | Has GitHub Actions or other CI configured |
| Tests Present | Has test files or test commands |
| Lint/Format | Has linting or formatting configured |
| README Quality | Has comprehensive documentation |
| Security Scan | Has security scanning workflow |

## Maintenance

- **Weekly**: Run refresh script to catch new projects
- **Monthly**: Review archived/stale projects
- **Quarterly**: Audit naming convention compliance

## License

Private repository - internal use only.
