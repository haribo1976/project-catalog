# Versioning and Release Standards

This document defines the versioning scheme and release process for all projects in the haribo1976 portfolio.

## Semantic Versioning

All projects follow [Semantic Versioning 2.0.0](https://semver.org/):

```
MAJOR.MINOR.PATCH[-PRERELEASE]
```

| Component | When to Increment |
|-----------|-------------------|
| **MAJOR** | Breaking changes, incompatible API changes |
| **MINOR** | New features, backwards-compatible |
| **PATCH** | Bug fixes, backwards-compatible |
| **PRERELEASE** | Development stages (alpha, beta, rc) |

## Pre-release Stages

| Stage | Format | Description |
|-------|--------|-------------|
| **Alpha** | `v0.1.0-alpha` | Early development, unstable, incomplete features |
| **Beta** | `v0.1.0-beta` | Feature-complete, testing phase, may have bugs |
| **Release Candidate** | `v0.1.0-rc.1` | Production-ready candidate, final testing |
| **Stable** | `v1.0.0` | Production-ready, fully supported |

### Incrementing Pre-releases

When making updates within a pre-release stage:

```
v0.1.0-alpha    → v0.1.0-alpha.1 → v0.1.0-alpha.2
v0.1.0-beta     → v0.1.0-beta.1  → v0.1.0-beta.2
v0.1.0-rc.1     → v0.1.0-rc.2    → v0.1.0-rc.3
```

## Release Title Format

All releases use a consistent title format:

```
{Display Name} v{VERSION}
```

Examples:
- `M365 Admin Hub v0.1.0-alpha`
- `Azure WAF Monitor v0.2.0-beta`
- `ISMS Portal v1.0.0`

## Release Notes Template

```markdown
## What's Changed

### Features
- Feature 1
- Feature 2

### Bug Fixes
- Fix 1
- Fix 2

### Breaking Changes
- Change 1 (if applicable)

## Status
- **Version**: X.Y.Z
- **Stage**: Alpha/Beta/RC/Stable
- **Production Ready**: Yes/No

## Upgrade Notes
Instructions for upgrading from previous version (if applicable).
```

## Git Tags

All releases are tagged in git with the version number:

```bash
git tag -a v0.1.0-alpha -m "Release v0.1.0-alpha"
git push origin v0.1.0-alpha
```

## Creating Releases

### Single Project

```bash
gh release create v0.1.0-alpha \
  --repo haribo1976/project-name \
  --title "Project Name v0.1.0-alpha" \
  --notes "Release notes here" \
  --prerelease
```

### All Projects

Use the bulk release script:

```bash
./scripts/create_releases.sh --version v0.2.0-alpha --stage alpha
```

## Version Progression Example

Typical version progression for a project:

```
v0.1.0-alpha     # Initial development
v0.1.0-alpha.1   # Alpha updates
v0.1.0-beta      # Feature complete, testing
v0.1.0-beta.1    # Beta fixes
v0.1.0-rc.1      # Release candidate
v0.1.0           # First stable release
v0.1.1           # Patch release
v0.2.0           # Minor feature release
v1.0.0           # Major stable release
```

## Project Status by Version

| Version Range | Status | Support Level |
|---------------|--------|---------------|
| `v0.x.x-alpha` | Development | No support |
| `v0.x.x-beta` | Testing | Limited support |
| `v0.x.x-rc.x` | Pre-production | Bug fixes only |
| `v1.x.x+` | Production | Full support |

## Current Portfolio Status

All projects are currently at `v0.1.0-alpha` (January 2026).

See [catalog/projects.md](../catalog/projects.md) for the full project listing.
