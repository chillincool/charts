# Renovate Setup

This repository uses [Renovate](https://docs.renovatebot.com/) for automated dependency management.

## What Renovate Does

- **Monitors container images** in `charts/*/values.yaml` for updates
- **Creates PRs automatically** when new container versions are available
- **Groups updates** to avoid PR spam (all container updates in one PR)
- **Runs every 6 hours** instead of every 15 minutes (192 runs/day → 4 runs/day)

## Configuration

See `renovate.json` in the root directory.

### Key Settings

- **Schedule**: Every 6 hours (vs previous 15-minute polling)
- **Grouping**: All container image updates grouped together
- **Auto-merge**: Disabled (you review PRs manually)
- **Max PRs**: 5 concurrent PRs at a time
- **Labels**: Automatically adds `dependencies` and `renovate` labels

## Enabling Renovate

### Option 1: GitHub App (Recommended)

1. Install the [Renovate GitHub App](https://github.com/apps/renovate)
2. Grant access to this repository
3. Renovate will automatically detect `renovate.json` and start monitoring

### Option 2: Self-Hosted

Add this workflow:

```yaml
name: Renovate
on:
  schedule:
    - cron: '0 */6 * * *'  # Every 6 hours
  workflow_dispatch:

jobs:
  renovate:
    runs-on: ubuntu-latest
    steps:
      - uses: renovatebot/github-action@v40.0.0
        with:
          token: ${{ secrets.RENOVATE_TOKEN }}
```

## What Changed

**Before:**
- `update-chart.yml`: Ran every 15 minutes (96 times/day)
- `auto-scaffold-charts.yml`: Ran every 15 minutes (96 times/day)
- Total: 192 scheduled workflow runs per day

**After:**
- Renovate: Runs every 6 hours (4 times/day) on Mend's infrastructure
- `release.yml`: Only runs when chart files change (path filter)
- `update-chart.yml`: Manual trigger only
- `auto-scaffold-charts.yml`: Manual trigger only

**Result:** ~98% reduction in workflow runs, same functionality.

## Workflow

1. Renovate detects new container image version
2. Creates PR with chart version bump and image tag update
3. You review the PR
4. Merge PR → triggers `release.yml` workflow (path filter matches)
5. Release workflow packages and publishes updated chart

## Customization

Edit `renovate.json` to:
- Change update schedule
- Enable auto-merge for patch updates
- Add package-specific rules
- Configure branch naming, commit messages, etc.

See [Renovate docs](https://docs.renovatebot.com/configuration-options/) for all options.
