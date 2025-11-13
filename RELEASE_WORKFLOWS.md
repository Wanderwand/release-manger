# Standardized Release Workflows

This document provides standardized workflows for releasing TypeScript/JavaScript projects with proper version management, changelog generation, and tagging.

## Table of Contents

1. [Overview](#overview)
2. [Release Types](#release-types)
3. [Core Concepts](#core-concepts)
4. [Setup & Configuration](#setup--configuration)
5. [Release Workflows](#release-workflows)
6. [Monorepo Support](#monorepo-support)
7. [Troubleshooting](#troubleshooting)

---

## Overview

### Goals

- **Standardized**: Same versioning, changelog, and tagging across all projects
- **Automated**: Minimize manual steps, reduce human error
- **Flexible**: Support different project types and deployment targets
- **Traceable**: Clear audit trail of what changed and when
- **Scalable**: Works for single repos and monorepos

### Release Pipeline Stages

```
┌─────────────────────────────────────────────────────────────┐
│ 1. TRIGGER                                                  │
│    Manual dispatch or automatic on tag/schedule             │
└──────────────────────┬──────────────────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────────────────┐
│ 2. PREPARE                                                  │
│    ├─ Determine version bump                               │
│    ├─ Update version files                                 │
│    ├─ Generate changelog                                   │
│    ├─ Create commit                                        │
│    └─ Create git tag                                       │
└──────────────────────┬──────────────────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────────────────┐
│ 3. BUILD                                                    │
│    ├─ Install dependencies                                 │
│    ├─ Run tests                                            │
│    ├─ Build/compile                                        │
│    └─ Generate artifacts                                   │
└──────────────────────┬──────────────────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────────────────┐
│ 4. PUBLISH (Conditional based on type)                     │
│    ├─ npm publish                                          │
│    ├─ Docker push                                          │
│    ├─ GitHub Release creation                              │
│    ├─ Chrome Web Store                                     │
│    └─ Other targets...                                     │
└──────────────────────┬──────────────────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────────────────┐
│ 5. VERIFY                                                   │
│    ├─ Confirm artifact availability                        │
│    └─ Post-release checks                                  │
└──────────────────────────────────────────────────────────────┘
```

---

## Release Types

### 1. NPM Package Release

**Target**: npm registry (npmjs.com)

**Use cases**: Libraries, SDKs, CLI tools, any npm package

**Key considerations**:
- npm credentials required (.npmrc)
- Semantic versioning (semver)
- Public vs private packages
- Scoped packages (@org/package-name)

**Process**:
```bash
1. Determine new version (e.g., 1.2.0 → 1.3.0)
2. Update package.json version
3. Generate/update CHANGELOG.md
4. Commit: "chore(release): v1.3.0"
5. Tag: git tag v1.3.0
6. Run: npm publish
```

### 2. Docker Image Release

**Target**: Docker registries (Docker Hub, ECR, GCR, etc.)

**Use cases**: Services, applications, tools

**Key considerations**:
- Registry credentials
- Image naming conventions
- Tag strategy (v1.2.3, latest, semver tags)
- Multi-architecture builds
- Layer caching

**Process**:
```bash
1. Determine new version
2. Build Docker image: docker build -t myapp:v1.3.0 .
3. Tag variants: myapp:latest, myapp:1.3, myapp:1.3.0
4. Push to registry: docker push myapp:v1.3.0
```

### 3. GitHub Release + Artifacts

**Target**: GitHub Releases page

**Use cases**: Downloadable binaries, cross-platform tools, assets

**Key considerations**:
- Build for multiple platforms (Linux, macOS, Windows)
- Generate checksums/signatures
- Release notes from changelog
- Pre-release vs release versions

**Process**:
```bash
1. Determine new version
2. Build artifacts for each platform
3. Generate checksums: sha256sum myapp-linux-x64
4. Create GitHub Release with artifacts
5. Upload release notes from CHANGELOG.md
```

### 4. Chrome Extension Release

**Target**: Chrome Web Store

**Use cases**: Browser extensions

**Key considerations**:
- Chrome Web Store API authentication
- manifest.json versioning
- Review process timing
- Staged rollout options

**Process**:
```bash
1. Determine new version
2. Update manifest.json version
3. Build extension ZIP
4. Upload via Chrome Web Store API or manual upload
5. Handle review/approval process
```

### 5. Static Site / GitHub Pages

**Target**: GitHub Pages or other static hosting

**Use cases**: Documentation, landing pages, SPA applications

**Key considerations**:
- Build output location (dist/, docs/)
- Deploy on every commit vs tagged releases
- Versioning in assets
- Cache busting

**Process**:
```bash
1. Build static site: npm run build
2. Deploy to GitHub Pages or CDN
3. Optionally tag release version
```

### 6. Binary/Executable Release

**Target**: Self-hosted or artifact storage

**Use cases**: CLI tools, executables, compiled binaries

**Key considerations**:
- Cross-platform compilation
- Binary signing/codesigning
- Checksum verification
- Installation scripts

**Process**:
```bash
1. Determine new version
2. Compile for each target OS/arch
3. Sign binaries if required
4. Generate checksums
5. Host on web server or include in GitHub Release
```

---

## Core Concepts

### Semantic Versioning (SemVer)

Format: `MAJOR.MINOR.PATCH[-PRERELEASE][+BUILD]`

```
1.2.3
│ │ └─ PATCH: Bug fixes (increment on fixes)
│ └─── MINOR: New features (increment on features)
└───── MAJOR: Breaking changes (increment on breaking)

Examples:
1.0.0          → Initial release
1.1.0          → New feature added
1.1.1          → Bug fix
2.0.0          → Breaking change
1.0.0-rc.1     → Release candidate
1.0.0+build.1  → Build metadata
```

**Version Bump Rules**:
- **Major** (x.0.0): Breaking changes, incompatible API changes
- **Minor** (0.x.0): New features, backwards compatible
- **Patch** (0.0.x): Bug fixes, no API changes
- **Prerelease** (0.0.0-alpha, 0.0.0-beta): Development versions
- **Metadata** (0.0.0+build.1): Build info, doesn't affect precedence

### Conventional Commits

Format for automatic version detection:

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

**Types** (impact on versioning):
- `feat`: New feature → MINOR bump
- `fix`: Bug fix → PATCH bump
- `BREAKING CHANGE`: Breaking change → MAJOR bump
- `refactor`, `style`, `docs`: PATCH bump
- `chore`, `ci`: No version bump (pre-release only)

**Examples**:
```
feat: add dark mode support          → v1.1.0
fix: resolve memory leak in cache    → v1.0.1
BREAKING CHANGE: remove legacy API  → v2.0.0
chore: update dependencies           → v1.0.0-rc.1
```

### Changelog Generation

Automated from commit messages:

```
# Changelog

## [1.3.0] - 2024-01-15

### Added
- Dark mode support (#123)
- New authentication provider (#124)

### Fixed
- Memory leak in cache manager (#125)
- Incorrect error messages (#126)

### Changed
- Updated dependencies

### Breaking Changes
- Removed deprecated `legacyAPI()` method

## [1.2.0] - 2024-01-08

### Added
- Export new utility functions
```

### Git Tagging

Tag format: `v{VERSION}` for single repos, `{PACKAGE}@{VERSION}` for monorepos

```bash
# Single repo
git tag v1.2.3

# Monorepo (scoped packages)
git tag packages/cli@1.2.3
git tag packages/sdk@2.0.0

# Annotated tags (recommended)
git tag -a v1.2.3 -m "Release version 1.2.3"
```

---

## Setup & Configuration

### Step 1: Add Release Configuration

Create `.github/release-config.yml` in your repository:

```yaml
# Release configuration for your project

# Configuration version
version: 1

# Project type
# Options: npm-package, docker-image, chrome-extension, github-release, static-site, binary
projectType: npm-package

# Versioning configuration
versioning:
  # Strategy: semantic (semver) or calendar (YYYY.MM.DD)
  strategy: semantic
  
  # Files to update with new version
  versionFiles:
    - package.json
    - package-lock.json

# Changelog configuration
changelog:
  enabled: true
  # Style: conventional-commits or manual
  style: conventional-commits
  # Output file
  file: CHANGELOG.md
  # Include unreleased section
  includeUnreleased: true

# Monorepo configuration (optional)
monorepo:
  # Set to true if this is a monorepo
  enabled: false
  # Workspaces/packages to manage
  # workspaces:
  #   - packages/cli
  #   - packages/sdk

# Release triggers and conditions
release:
  # Branch to release from
  branch: main
  
  # Require PR checks to pass
  requireChecks: true
  
  # Require approval before release
  requireApproval: false

# Deployment configuration
deployments:
  - name: npm
    enabled: true
    description: "Publish to npm registry"
    
  - name: github-release
    enabled: true
    description: "Create GitHub Release with artifacts"
    
  - name: docker
    enabled: false
    description: "Push Docker image"
    
  - name: github-pages
    enabled: false
    description: "Deploy to GitHub Pages"

# Pre-release configuration
prerelease:
  # Pre-release version prefix
  suffix: rc
  # Auto-increment pre-release patch
  autoIncrement: true

# Notification configuration
notifications:
  # Slack webhook URL (optional)
  slackWebhook: ""
  # Email recipients (optional)
  email: []
```

### Step 2: Install Dependencies

Add dependencies to your `package.json`:

```bash
npm install --save-dev \
  commitizen \
  cz-conventional-changelog \
  standard-version \
  @commitlint/cli \
  @commitlint/config-conventional \
  husky
```

Or for a fresh setup:

```json
{
  "devDependencies": {
    "@commitlint/cli": "^18.0.0",
    "@commitlint/config-conventional": "^18.0.0",
    "commitizen": "^4.3.0",
    "cz-conventional-changelog": "^3.3.0",
    "husky": "^8.0.3",
    "standard-version": "^9.5.0"
  },
  "config": {
    "commitizen": {
      "path": "./node_modules/cz-conventional-changelog"
    }
  }
}
```

### Step 3: Configure Commit Hooks

Initialize husky:

```bash
npx husky install
npx husky add .husky/commit-msg 'npx --no -- commitlint --edit "$1"'
npx husky add .husky/prepare-commit-msg 'exec < /dev/tty && npx cz --hook || true'
```

This creates `.husky/` hooks that:
- Validate commit messages follow conventional commits
- Provide interactive commit message builder (commitizen)

### Step 4: Add npm Scripts

Add to `package.json`:

```json
{
  "scripts": {
    "release": "standard-version",
    "release:minor": "standard-version --release-as minor",
    "release:major": "standard-version --release-as major",
    "release:patch": "standard-version --release-as patch",
    "release:pre": "standard-version --prerelease rc"
  }
}
```

---

## Release Workflows

### Quick Start: npm Package Release

#### Option A: Manual Release (Local)

```bash
# 1. Ensure you're on main and up to date
git checkout main
git pull origin main

# 2. Run release script (updates version, changelog, creates tag)
npm run release

# 3. Review changes
git log -1
cat CHANGELOG.md

# 4. Push to repository (including tags)
git push origin main --follow-tags

# 5. npm automatically publishes (if GitHub Actions configured)
# OR publish manually:
npm publish
```

#### Option B: Automated Release (GitHub Actions)

1. Create `.github/workflows/release.yml` (see templates below)
2. Manually trigger release from GitHub Actions tab
3. Or automatically on tag push:
   ```bash
   git tag v1.2.3
   git push origin v1.2.3
   ```

### Release Workflow: Single Repo npm Package

**Trigger**: Manual dispatch or tag push

**Steps**:

1. **Version & Changelog** (automated)
   - Detect version bump from conventional commits
   - Update `package.json` and `package-lock.json`
   - Generate `CHANGELOG.md` entry
   - Create commit: `chore(release): v1.2.3`
   - Create git tag: `v1.2.3`
   - Push to repository

2. **Build & Test** (automated)
   - `npm ci` - install dependencies
   - `npm run lint` - run linter
   - `npm run test` - run tests
   - `npm run build` - build project (if applicable)

3. **Publish** (automated)
   - Check npm registry credentials
   - `npm publish` - publish to npm
   - Create GitHub Release with changelog
   - Post release notes

### Release Workflow: Docker Image

**Trigger**: Manual dispatch or on release tag

**Steps**:

1. **Build Docker image**
   ```bash
   docker build -t myapp:$VERSION .
   docker build -t myapp:latest .
   ```

2. **Push to registry**
   ```bash
   docker tag myapp:$VERSION registry.example.com/myapp:$VERSION
   docker push registry.example.com/myapp:$VERSION
   docker push registry.example.com/myapp:latest
   ```

3. **Update deployment**
   - Deploy new image to relevant environments
   - Verify service health

### Release Workflow: GitHub Release with Artifacts

**Trigger**: Manual dispatch

**Steps**:

1. **Build artifacts**
   ```bash
   npm run build
   npm run dist  # Create distributable files
   ```

2. **Generate checksums**
   ```bash
   sha256sum dist/app-linux-x64 > dist/app-linux-x64.sha256
   sha256sum dist/app-darwin-x64 > dist/app-darwin-x64.sha256
   ```

3. **Create GitHub Release**
   - Create tag and release
   - Upload all artifacts
   - Add release notes from changelog

4. **Verify**
   - Visit Releases page
   - Confirm all assets are available
   - Verify checksums match

---

## Monorepo Support

For monorepo projects (using workspaces), additional considerations:

### Configuration

```yaml
monorepo:
  enabled: true
  workspaces:
    - packages/cli
    - packages/sdk
    - packages/ui
```

### Version Management

Each workspace has independent versioning:

```
packages/
├── cli/
│   ├── package.json (version: 1.2.3)
│   └── CHANGELOG.md
├── sdk/
│   ├── package.json (version: 2.1.0)
│   └── CHANGELOG.md
└── ui/
    ├── package.json (version: 3.0.0)
    └── CHANGELOG.md
```

### Git Tagging

Use scoped tags to identify which package a release is for:

```bash
git tag packages/cli@1.2.3
git tag packages/sdk@2.1.0
git tag packages/ui@3.0.0
```

### Release Process

Only release packages that have changed:

```bash
# Option 1: Release specific package
npm run release:cli

# Option 2: Use Changesets workflow
npm run changeset
npm run changeset:version
npm run changeset:publish
```

### Tools

Popular monorepo release tools:

- **Changesets** - Track changes per package, coordinate releases
- **Lerna** - Package manager for monorepos with versioning
- **Turborepo** - Monorepo build tool with changesets integration

---

## GitHub Actions Workflows

### Template 1: npm Package - Auto Release

File: `.github/workflows/release.yml`

```yaml
name: Release

on:
  push:
    tags:
      - 'v*'

jobs:
  release:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      id-token: write

    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - uses: actions/setup-node@v4
        with:
          node-version: '18'
          registry-url: 'https://registry.npmjs.org'

      - run: npm ci
      - run: npm run lint --if-present
      - run: npm run test --if-present
      - run: npm run build --if-present

      - run: npm publish
        env:
          NODE_AUTH_TOKEN: ${{ secrets.NPM_TOKEN }}
      
      - name: Create Release
        uses: actions/create-release@v1
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        with:
          tag_name: ${{ github.ref }}
          release_name: Release ${{ github.ref }}
          body_path: ./CHANGELOG.md
          draft: false
          prerelease: false
```

### Template 2: Manual Release Workflow

File: `.github/workflows/manual-release.yml`

```yaml
name: Manual Release

on:
  workflow_dispatch:
    inputs:
      releaseType:
        description: 'Release type'
        required: true
        default: 'patch'
        type: choice
        options:
          - major
          - minor
          - patch
          - prerelease

jobs:
  release:
    runs-on: ubuntu-latest
    permissions:
      contents: write
      id-token: write

    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - uses: actions/setup-node@v4
        with:
          node-version: '18'
          registry-url: 'https://registry.npmjs.org'

      - run: npm ci

      - name: Configure Git
        run: |
          git config user.name "GitHub Actions"
          git config user.email "actions@github.com"

      - name: Run Release
        run: |
          if [ "${{ inputs.releaseType }}" = "prerelease" ]; then
            npm run release:pre
          else
            npm run release:${{ inputs.releaseType }}
          fi

      - name: Push changes
        run: git push origin main --follow-tags

      - name: Run tests
        run: npm run test --if-present

      - name: Build
        run: npm run build --if-present

      - name: Publish to npm
        run: npm publish
        env:
          NODE_AUTH_TOKEN: ${{ secrets.NPM_TOKEN }}
```

### Template 3: Docker Release

File: `.github/workflows/docker-release.yml`

```yaml
name: Docker Release

on:
  push:
    tags:
      - 'v*'

jobs:
  docker:
    runs-on: ubuntu-latest
    permissions:
      contents: read

    steps:
      - uses: actions/checkout@v4

      - name: Extract version
        id: version
        run: echo "VERSION=${GITHUB_REF#refs/tags/v}" >> $GITHUB_OUTPUT

      - uses: docker/setup-buildx-action@v3

      - uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_PASSWORD }}

      - uses: docker/build-push-action@v5
        with:
          context: .
          push: true
          tags: |
            ${{ secrets.DOCKER_REGISTRY }}/myapp:${{ steps.version.outputs.VERSION }}
            ${{ secrets.DOCKER_REGISTRY }}/myapp:latest
          cache-from: type=registry,ref=${{ secrets.DOCKER_REGISTRY }}/myapp:buildcache
          cache-to: type=registry,ref=${{ secrets.DOCKER_REGISTRY }}/myapp:buildcache,mode=max
```

---

## Troubleshooting

### Issue: "npm ERR! 403 Forbidden"

**Cause**: Incorrect npm credentials or package already published

**Solution**:
1. Check `.npmrc` has valid token: `cat ~/.npmrc`
2. Regenerate npm token: https://www.npmjs.com/settings/~/tokens
3. Update GitHub secret `NPM_TOKEN` with new token
4. Ensure `package.json` version is unique

### Issue: "Git tag already exists"

**Cause**: Attempting to create tag that already exists

**Solution**:
```bash
# Delete local tag
git tag -d v1.2.3

# Delete remote tag
git push origin :refs/tags/v1.2.3

# Create new tag with correct version
npm run release:patch
```

### Issue: "CHANGELOG.md merge conflicts"

**Cause**: Multiple PRs merged before releasing

**Solution**:
1. Resolve conflicts manually in CHANGELOG.md
2. Or regenerate from commits:
   ```bash
   git stash
   git checkout main
   git pull
   npm run release
   ```

### Issue: "Commit history doesn't follow conventional commits"

**Cause**: Commits don't match conventional commit format

**Solution**:
1. Use commitizen to create properly formatted commits:
   ```bash
   npm run commit  # or npx cz
   ```

2. Or manually amend commit:
   ```bash
   git commit --amend -m "feat: add new feature"
   ```

### Issue: "Action failed: npm publish - not authorized"

**Cause**: `NODE_AUTH_TOKEN` secret not configured

**Solution**:
1. Go to repository Settings → Secrets
2. Create `NPM_TOKEN` secret
3. Add to workflow env: `NODE_AUTH_TOKEN: ${{ secrets.NPM_TOKEN }}`

---

## Best Practices

1. **Commit Early, Commit Often**: Makes changelog generation clearer
2. **Use Conventional Commits**: Enables automated version detection
3. **Write Meaningful Messages**: Changelog will include these
4. **Test Before Release**: Catch issues early
5. **Tag All Releases**: Enables rollback and tracking
6. **Sign Releases**: Use GPG signatures for security
7. **Document Changes**: Update CHANGELOG.md with breaking changes
8. **Verify Artifacts**: Check published packages/images
9. **Maintain Consistent Versions**: Coordinate in monorepos
10. **Automate Manually Tested Deployments**: Reduce human error

---

## References

- [Semantic Versioning](https://semver.org/)
- [Conventional Commits](https://www.conventionalcommits.org/)
- [standard-version](https://github.com/conventional-changelog/standard-version)
- [commitizen](https://github.com/commitizen/cz-cli)
- [GitHub Actions](https://docs.github.com/en/actions)
