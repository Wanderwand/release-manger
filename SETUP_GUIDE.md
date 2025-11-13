# Release Workflow Setup Guide

This guide walks you through setting up standardized release workflows in your project.

## Table of Contents

1. [Choose Your Release Type](#choose-your-release-type)
2. [Project Setup Steps](#project-setup-steps)
3. [Configure GitHub Secrets](#configure-github-secrets)
4. [Test the Workflow](#test-the-workflow)
5. [First Release](#first-release)
6. [Ongoing Usage](#ongoing-usage)

---

## Choose Your Release Type

Select which workflows are relevant for your project:

### npm Package

If you're publishing to npm registry:

```bash
# Copy configuration template
cp .github/release-config.example.yml .github/release-config.yml

# Edit for npm
cat > .github/release-config.yml << 'EOF'
version: 1
projectType: npm-package
versioning:
  strategy: semantic
  versionFiles:
    - package.json
changelog:
  enabled: true
  style: conventional-commits
  file: CHANGELOG.md
deployments:
  - name: npm
    enabled: true
  - name: github-release
    enabled: true
EOF
```

### Docker Image

If you're building Docker images:

```bash
cat > .github/release-config.yml << 'EOF'
version: 1
projectType: docker-image
versioning:
  strategy: semantic
  versionFiles: []  # Docker doesn't use package.json
changelog:
  enabled: true
deployments:
  - name: docker
    enabled: true
  - name: github-release
    enabled: true
EOF
```

### Chrome Extension

If you're developing a Chrome extension:

```bash
cat > .github/release-config.yml << 'EOF'
version: 1
projectType: chrome-extension
versioning:
  strategy: semantic
  versionFiles:
    - manifest.json
changelog:
  enabled: true
deployments:
  - name: chrome-extension
    enabled: true
  - name: github-release
    enabled: true
EOF
```

### Static Site / GitHub Pages

If you're deploying a static site:

```bash
cat > .github/release-config.yml << 'EOF'
version: 1
projectType: static-site
changelog:
  enabled: false  # Optional for static sites
deployments:
  - name: github-pages
    enabled: true
EOF
```

---

## Project Setup Steps

### Step 1: Install Release Tools

```bash
npm install --save-dev \
  commitizen \
  cz-conventional-changelog \
  standard-version \
  @commitlint/cli \
  @commitlint/config-conventional \
  husky
```

### Step 2: Initialize Husky

```bash
npx husky install
npx husky add .husky/commit-msg 'npx --no -- commitlint --edit "$1"'
npx husky add .husky/prepare-commit-msg 'exec < /dev/tty && npx cz --hook || true'
```

### Step 3: Add npm Scripts

Edit `package.json` and add:

```json
{
  "scripts": {
    "commit": "cz",
    "release": "standard-version",
    "release:major": "standard-version --release-as major",
    "release:minor": "standard-version --release-as minor",
    "release:patch": "standard-version --release-as patch",
    "release:pre": "standard-version --prerelease rc"
  }
}
```

### Step 4: Create Commitizen Configuration

Add to `package.json`:

```json
{
  "config": {
    "commitizen": {
      "path": "./node_modules/cz-conventional-changelog"
    }
  }
}
```

### Step 5: Create Commitlint Configuration

Create `.commitlintrc.json`:

```json
{
  "extends": ["@commitlint/config-conventional"],
  "rules": {
    "type-enum": [
      2,
      "always",
      ["feat", "fix", "docs", "style", "refactor", "perf", "test", "chore", "ci", "revert"]
    ],
    "subject-full-stop": [2, "never", "."],
    "subject-case": [2, "never", ["start-case", "pascal-case", "upper-case"]],
    "type-case": [2, "always", "lowercase"]
  }
}
```

### Step 6: Create .gitignore

Create `.gitignore` with essential entries:

```
# Dependencies
node_modules/
*.npm
.npm
package-lock.json

# Build artifacts
dist/
build/
out/
*.bundle.*

# IDE
.vscode/
.idea/
*.swp
*.swo
*~

# OS
.DS_Store
Thumbs.db

# Environment
.env
.env.local
.env.*.local

# Temporary
*.tmp
.cache/
temp/
```

### Step 7: Enable GitHub Actions

GitHub Actions is built into GitHub. Make sure your repository has Actions enabled:

1. Go to Settings → Actions
2. Ensure "Allow all actions and reusable workflows" is selected

### Step 8: Make Initial Commit with Proper Format

```bash
# Stage everything
git add .

# Use commitizen to create a properly formatted commit
npm run commit

# Or manually create with proper format:
git commit -m "feat: initial project setup with release workflows"

# Push to repository
git push origin main
```

---

## Configure GitHub Secrets

Different workflows require different secrets. Configure based on your deployment needs:

### For npm Publishing

1. Go to Settings → Secrets and Variables → Actions
2. Click "New repository secret"
3. Add `NPM_TOKEN`:
   - Generate at: https://www.npmjs.com/settings/~/tokens
   - Create "Granular Access Token"
   - Select: "Packages: Write" permission
   - Add to GitHub as secret

### For Docker Registry (ghcr.io)

1. Create personal access token:
   - GitHub Settings → Developer settings → Personal access tokens
   - Select "Packages: read and write"
   - Copy token

2. Add GitHub secret `GHCR_TOKEN` with the token value
   - The workflow already uses GITHUB_TOKEN which is automatic

### For Chrome Web Store

1. Generate Chrome Web Store API credentials:
   - https://chrome.google.com/webstore/devconsole/
   - Settings → API access

2. Add GitHub secrets:
   - `CHROME_STORE_CLIENT_ID`
   - `CHROME_STORE_CLIENT_SECRET`
   - `CHROME_EXTENSION_ID`

### For Slack Notifications (Optional)

1. Create Slack webhook:
   - https://api.slack.com/messaging/webhooks

2. Add GitHub secret:
   - `SLACK_WEBHOOK_URL`

---

## Test the Workflow

### Test Pre-release

1. Make a test commit:
   ```bash
   git commit --allow-empty -m "test: release workflow"
   ```

2. Run local release script:
   ```bash
   npm run release:pre
   ```

3. Review generated changelog and version:
   ```bash
   cat CHANGELOG.md
   cat package.json | grep version
   git log -1
   ```

4. Don't push yet - reset if needed:
   ```bash
   git reset --hard HEAD~1
   ```

### Validate Conventional Commits

```bash
bash scripts/validate-conventional-commits.sh
```

### Run Preparation Checklist

```bash
bash scripts/prepare-release.sh --auto
```

---

## First Release

### Manual Release (Recommended for first time)

```bash
# 1. Ensure you're up to date
git checkout main
git pull origin main

# 2. Verify status
bash scripts/prepare-release.sh

# 3. Create release
npm run release:minor  # or major/patch as appropriate

# 4. Review changes
git log -1
git show HEAD
cat CHANGELOG.md

# 5. Push with tags
git push origin main --follow-tags

# 6. Verify GitHub Release was created
# Check: https://github.com/YOUR_ORG/YOUR_REPO/releases
```

### Automated Release (After first successful release)

1. Go to GitHub Actions tab
2. Click "Manual Release" workflow
3. Click "Run workflow"
4. Select release type (major/minor/patch/prerelease)
5. Click "Run workflow"
6. Monitor execution in Actions tab

---

## Ongoing Usage

### Daily Development: Using Conventional Commits

```bash
# Create feature
git checkout -b feature/add-auth

# Make changes
# ... coding ...

# Stage and commit using commitizen
git add .
npm run commit

# Select commit type: feat
# Enter scope: auth
# Enter subject: add JWT authentication
# Enter body: Implements JWT token generation and validation
# Enter breaking changes: none

# Git hooks will validate the commit message
# All good? Push your branch

git push origin feature/add-auth

# Create Pull Request on GitHub
```

### Before Release: Prepare

```bash
# Verify all PRs are merged to main
git checkout main
git pull origin main

# Run preparation checklist
bash scripts/prepare-release.sh --auto

# View commits since last release
git log $(git describe --tags --abbrev=0)..HEAD --oneline
```

### Create Release: Option A - Manual

```bash
npm run release:patch  # or minor/major

# Verify
git log -1
cat CHANGELOG.md

# Push
git push origin main --follow-tags
```

### Create Release: Option B - Automated (GitHub Actions)

1. GitHub Actions → Manual Release → Run workflow
2. Select release type
3. Done! Workflow handles everything

### Post-Release Verification

```bash
# Check npm package
npm view YOUR_PACKAGE_NAME@latest

# Check GitHub Release
# Visit: https://github.com/YOUR_ORG/YOUR_REPO/releases

# Check Docker image (if applicable)
# docker pull ghcr.io/YOUR_ORG/your-app:latest
```

---

## Troubleshooting Setup Issues

### Issue: Commitizen not prompting

**Solution**:
```bash
# Ensure .husky/prepare-commit-msg hook exists
cat .husky/prepare-commit-msg

# If missing:
npx husky add .husky/prepare-commit-msg 'exec < /dev/tty && npx cz --hook || true'
```

### Issue: Husky hooks not running

**Solution**:
```bash
# Install husky again
npx husky install

# Make hooks executable
chmod +x .husky/*
```

### Issue: Commitlint errors on commit

**Solution**:
```bash
# Validate commit format
echo "feat: test" | npx commitlint

# Fix commit manually
git commit --amend -m "feat: proper message format"
```

### Issue: GitHub Actions workflow not triggering

**Solution**:
1. Verify workflow file exists in `.github/workflows/`
2. Check workflow syntax (YAML valid)
3. Push to `main` branch
4. Wait 1-2 minutes for GitHub to pick up changes

---

## Quick Reference

### Commit Types

```
feat:      New feature
fix:       Bug fix
docs:      Documentation only
style:     Code style (no logic change)
refactor:  Code refactor (no logic change)
perf:      Performance improvement
test:      Test changes
chore:     Non-code changes (deps, config)
ci:        CI/CD changes
revert:    Revert previous commit
```

### Release Commands

```bash
npm run commit         # Interactive commit
npm run release        # Auto-detect version bump
npm run release:major  # Major release (breaking change)
npm run release:minor  # Minor release (new feature)
npm run release:patch  # Patch release (bug fix)
npm run release:pre    # Pre-release (rc, alpha, beta)
```

### Release Script Commands

```bash
bash scripts/prepare-release.sh        # Pre-release checklist
bash scripts/validate-conventional-commits.sh  # Validate commits
node scripts/generate-changelog.js     # Generate changelog
```

---

## Next Steps

1. ✅ Complete setup steps above
2. ✅ Create first release (manually)
3. ✅ Configure GitHub secrets for deployments
4. ✅ Test automated release workflow
5. ✅ Document project-specific release notes

For detailed information, see [RELEASE_WORKFLOWS.md](./RELEASE_WORKFLOWS.md)
