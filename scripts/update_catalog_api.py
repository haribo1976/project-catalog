#!/usr/bin/env python3
"""
update_catalog_api.py
Updates the project catalog using the GitHub API.
Designed to run in GitHub Actions on a daily schedule.
"""

import os
import sys
import json
import yaml
import requests
from datetime import datetime
from pathlib import Path

# Configuration
GITHUB_USER = os.environ.get("GITHUB_USER", "haribo1976")
GITHUB_TOKEN = os.environ.get("GITHUB_TOKEN")
CATALOG_DIR = Path(__file__).parent.parent / "catalog"

# GitHub API headers
HEADERS = {
    "Accept": "application/vnd.github+json",
    "X-GitHub-Api-Version": "2022-11-28",
}
if GITHUB_TOKEN:
    HEADERS["Authorization"] = f"Bearer {GITHUB_TOKEN}"


def get_repo_info(repo_name: str) -> dict:
    """Fetch repository information from GitHub API."""
    url = f"https://api.github.com/repos/{GITHUB_USER}/{repo_name}"
    response = requests.get(url, headers=HEADERS)

    if response.status_code == 200:
        return response.json()
    else:
        print(f"Warning: Could not fetch {repo_name}: {response.status_code}")
        return None


def get_latest_release(repo_name: str) -> dict:
    """Fetch latest release information from GitHub API."""
    url = f"https://api.github.com/repos/{GITHUB_USER}/{repo_name}/releases/latest"
    response = requests.get(url, headers=HEADERS)

    if response.status_code == 200:
        return response.json()

    # Try to get any release if no "latest"
    url = f"https://api.github.com/repos/{GITHUB_USER}/{repo_name}/releases"
    response = requests.get(url, headers=HEADERS)

    if response.status_code == 200:
        releases = response.json()
        if releases:
            return releases[0]

    return None


def get_default_branch_last_commit(repo_name: str, default_branch: str = "main") -> str:
    """Get the date of the last commit on the default branch."""
    url = f"https://api.github.com/repos/{GITHUB_USER}/{repo_name}/commits/{default_branch}"
    response = requests.get(url, headers=HEADERS)

    if response.status_code == 200:
        data = response.json()
        commit_date = data.get("commit", {}).get("committer", {}).get("date", "")
        if commit_date:
            return commit_date[:10]  # Return just the date part

    return None


def check_file_exists(repo_name: str, filepath: str) -> bool:
    """Check if a file exists in the repository."""
    url = f"https://api.github.com/repos/{GITHUB_USER}/{repo_name}/contents/{filepath}"
    response = requests.get(url, headers=HEADERS)
    return response.status_code == 200


def detect_scorecard(repo_name: str) -> dict:
    """Detect scorecard items for a repository."""
    scorecard = {
        "ci_present": check_file_exists(repo_name, ".github/workflows"),
        "tests_present": (
            check_file_exists(repo_name, "tests") or
            check_file_exists(repo_name, "__tests__") or
            check_file_exists(repo_name, "test")
        ),
        "lint_present": (
            check_file_exists(repo_name, ".eslintrc.js") or
            check_file_exists(repo_name, ".eslintrc.cjs") or
            check_file_exists(repo_name, "eslint.config.js") or
            check_file_exists(repo_name, ".eslintrc.json")
        ),
        "readme_quality": "good" if check_file_exists(repo_name, "README.md") else "missing",
        "security_scan": check_file_exists(repo_name, ".github/workflows/security-scan.yml"),
    }
    return scorecard


def update_project(project: dict) -> dict:
    """Update a single project with latest GitHub data."""
    repo_name = project["name"]
    print(f"Updating {repo_name}...")

    # Get repo info
    repo_info = get_repo_info(repo_name)
    if repo_info:
        project["status"] = "archived" if repo_info.get("archived") else "active"

        # Update last commit date
        default_branch = repo_info.get("default_branch", "main")
        last_commit = get_default_branch_last_commit(repo_name, default_branch)
        if last_commit:
            project["last_commit"] = last_commit

        # Update language if detected
        if repo_info.get("language"):
            project["language"] = repo_info["language"]

    # Get latest release
    release = get_latest_release(repo_name)
    if release:
        project["release"] = {
            "version": release.get("tag_name", "unknown"),
            "stage": "alpha" if "alpha" in release.get("tag_name", "") else (
                "beta" if "beta" in release.get("tag_name", "") else (
                    "rc" if "rc" in release.get("tag_name", "") else "stable"
                )
            ),
            "prerelease": release.get("prerelease", False),
            "url": release.get("html_url", ""),
        }

    # Update scorecard (only if we have API access - skip in rate-limited scenarios)
    if repo_info:
        project["scorecard"] = detect_scorecard(repo_name)

    return project


def generate_markdown(projects: list) -> str:
    """Generate the projects.md file from project data."""
    today = datetime.now().strftime("%Y-%m-%d")

    # Count statistics
    total = len(projects)
    active = sum(1 for p in projects if p.get("status") == "active")
    archived = sum(1 for p in projects if p.get("status") == "archived")
    with_ci = sum(1 for p in projects if p.get("scorecard", {}).get("ci_present"))
    with_releases = sum(1 for p in projects if p.get("release"))

    md = f"""# Project Catalog

> Last updated: {today}

## Summary

| Metric | Count |
|--------|-------|
| **Total Projects** | {total} |
| **Active** | {active} |
| **Archived** | {archived} |
| **With CI** | {with_ci} |
| **With Releases** | {with_releases} |

---

## All Projects

| Project | Display Name | Version | Status | Category |
|---------|--------------|---------|--------|----------|
"""

    for p in sorted(projects, key=lambda x: x["name"]):
        name = p["name"]
        display = p.get("display_name", name)
        version = p.get("release", {}).get("version", "N/A")
        version_url = p.get("release", {}).get("url", "")
        status = p.get("status", "unknown")
        category = p.get("category", "unknown")

        version_link = f"[{version}]({version_url})" if version_url else version
        md += f"| [{name}](https://github.com/{GITHUB_USER}/{name}) | {display} | {version_link} | {status} | {category} |\n"

    # Add scorecard section
    md += """
---

## Scorecard Summary

| Project | Version | CI | Tests | Lint | README | Security |
|---------|---------|:--:|:-----:|:----:|:------:|:--------:|
"""

    for p in sorted(projects, key=lambda x: x["name"]):
        name = p["name"]
        version = p.get("release", {}).get("version", "N/A")
        sc = p.get("scorecard", {})

        ci = "✅" if sc.get("ci_present") else "❌"
        tests = "✅" if sc.get("tests_present") else "❌"
        lint = "✅" if sc.get("lint_present") else "❌"
        readme = "✅" if sc.get("readme_quality") == "good" else ("⚠️" if sc.get("readme_quality") == "minimal" else "❌")
        security = "✅" if sc.get("security_scan") else "❌"

        md += f"| {name} | {version} | {ci} | {tests} | {lint} | {readme} | {security} |\n"

    md += """
**Legend:** ✅ = Present | ❌ = Missing | ⚠️ = Minimal/Needs Improvement

---

## Version History

| Date | Version | Notes |
|------|---------|-------|
| 2026-02-01 | v0.1.0-alpha | Initial pre-release for all projects |

See [docs/VERSIONING.md](../docs/VERSIONING.md) for versioning standards.
"""

    return md


def main():
    """Main function to update the catalog."""
    print("=" * 50)
    print("Project Catalog Update")
    print(f"GitHub User: {GITHUB_USER}")
    print(f"Catalog Dir: {CATALOG_DIR}")
    print("=" * 50)

    # Load current catalog
    yaml_path = CATALOG_DIR / "projects.yaml"
    if not yaml_path.exists():
        print(f"Error: {yaml_path} not found")
        sys.exit(1)

    with open(yaml_path, "r") as f:
        catalog = yaml.safe_load(f)

    projects = catalog.get("projects", [])
    print(f"Found {len(projects)} projects to update")
    print()

    # Update each project
    updated_projects = []
    for project in projects:
        updated = update_project(project)
        updated_projects.append(updated)

    # Update the catalog
    catalog["projects"] = updated_projects

    # Add metadata
    catalog["_metadata"] = {
        "last_updated": datetime.now().strftime("%Y-%m-%d %H:%M:%S UTC"),
        "generator": "update_catalog_api.py",
    }

    # Write updated YAML
    # Custom representer to handle strings properly
    def str_representer(dumper, data):
        if '\n' in data:
            return dumper.represent_scalar('tag:yaml.org,2002:str', data, style='|')
        return dumper.represent_scalar('tag:yaml.org,2002:str', data)

    yaml.add_representer(str, str_representer)

    with open(yaml_path, "w") as f:
        f.write("# Project Catalog\n")
        f.write(f"# Last updated: {datetime.now().strftime('%Y-%m-%d')}\n")
        f.write("# Auto-generated by update_catalog_api.py\n\n")
        yaml.dump(catalog, f, default_flow_style=False, sort_keys=False, allow_unicode=True)

    print()
    print(f"Updated: {yaml_path}")

    # Generate and write markdown
    md_path = CATALOG_DIR / "projects.md"
    md_content = generate_markdown(updated_projects)

    with open(md_path, "w") as f:
        f.write(md_content)

    print(f"Updated: {md_path}")
    print()
    print("=" * 50)
    print("Catalog update complete!")
    print("=" * 50)


if __name__ == "__main__":
    main()
