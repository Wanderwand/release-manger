# Release Workflow Implementation Checklist

Use this checklist to implement standardized release workflows in your project.

## Pre-Implementation

- [ ] Review [README.md](./README.md) for overview
- [ ] Read [RELEASE_WORKFLOWS.md](./RELEASE_WORKFLOWS.md) for detailed information
- [ ] Choose your project type (npm, Docker, Chrome Extension, etc.)
- [ ] Determine if monorepo support needed

## Step 1: Copy Workflows

- [ ] Copy `.github/workflows/` directory to your project
  ```bash
  mkdir -p your-project/.github/workflows
  cp .github/workflows/*.yml your-project/.github/workflows/
  ```

- [ ] Copy helper scripts
  ```bash
  mkdir -p your-project/scripts
  cp scripts/* your-project/scripts/
  chmod +x your-project/scripts/*.sh
  ```

- [ ] Copy configuration template
  ```bash
  cp .github/release-config.example.yml your-project/.github/release-config.yml
  ```

## Step 2: Install Dependencies

- [ ] Install release management tools:
  ```bash
  npm install --save-dev \
    commitizen \
    cz-conventional-changelog \
    standard-version \
    @commitlint/cli \
    @commitlint/config-conventional \
    husky
  ```

## Step 3: Configure Tools

### Husky Setup

- [ ] Initialize husky:
  ```bash
  npx husky install
  ```

- [ ] Add commit message hook:
  ```bash
  npx husky add .husky/commit-msg 'npx --no -- commitlint --edit "$1"'
  ```

- [ ] Add prepare commit hook (optional, for interactive commits):
  ```bash
  npx husky add .husky/prepare-commit-msg 'exec < /dev/tty && npx cz --hook || true'
  ```

### Package.json Configuration

- [ ] Add release scripts to `package.json`:
  ```json
  {
    "scripts": {
      "commit": "cz",
      "release": "standard-version",
      "release:major": "standard-version --release-as major",
      "release:minor": "standard-version --release-as minor",
      "release:patch": "standard-version --release-as patch",
      "release:pre": "standard-version --prerelease rc"
    },
    "config": {
      "commitizen": {
        "path": "./node_modules/cz-conventional-changelog"
      }
    }
  }
  ```

### Commitlint Configuration

- [ ] Create `.commitlintrc.json` (copy from `examples/.commitlintrc.json`):
  ```json
  {
    "extends": ["@commitlint/config-conventional"]
  }
  ```

### Standard-version Configuration

- [ ] Create `.standard-versionrc.json` (copy from `examples/.standard-versionrc.json`)
  ```json
  {
    "types": [
      {"type": "feat", "section": "Features"},
      {"type": "fix", "section": "Bug Fixes"}
    ]
  }
  ```

### TypeScript Configuration (if applicable)

- [ ] Copy TypeScript configuration if not present
  ```bash
  cp examples/tsconfig.json your-project/ 2>/dev/null || echo "Skip if you have tsconfig.json"
  ```

### Linting Configuration (if applicable)

- [ ] ESLint config:
  ```bash
  cp examples/.eslintrc.json your-project/.eslintrc.json 2>/dev/null || true
  ```

- [ ] Jest config:
  ```bash
  cp examples/jest.config.js your-project/jest.config.js 2>/dev/null || true
  ```

### .gitignore

- [ ] Ensure `.gitignore` includes:
  ```
  node_modules/
  dist/
  build/
  .env
  .env.local
  .DS_Store
  ```

## Step 4: Configure Project Type

### For npm Package

- [ ] Edit `.github/release-config.yml`:
  ```yaml
  projectType: npm-package
  versioning:
    versionFiles:
      - package.json
      - package-lock.json
  deployments:
    - name: npm
      enabled: true
    - name: github-release
      enabled: true
  ```

- [ ] Disable workflows not needed:
  - [ ] Disable `docker-release.yml` (delete or rename)
  - [ ] Disable `chrome-extension-release.yml` (delete or rename)

### For Docker Image

- [ ] Create `Dockerfile` if not present
- [ ] Edit `.github/release-config.yml`:
  ```yaml
  projectType: docker-image
  deployments:
    - name: docker
      enabled: true
    - name: github-release
      enabled: true
  ```

- [ ] Disable unused workflows:
  - [ ] Disable `release.yml` (delete or rename)
  - [ ] Disable `chrome-extension-release.yml` (delete or rename)

### For Chrome Extension

- [ ] Ensure `manifest.json` exists with version field
- [ ] Edit `.github/release-config.yml`:
  ```yaml
  projectType: chrome-extension
  versioning:
    versionFiles:
      - manifest.json
  deployments:
    - name: chrome-extension
      enabled: true
    - name: github-release
      enabled: true
  ```

### For Monorepo

- [ ] Edit `.github/release-config.yml`:
  ```yaml
  monorepo:
    enabled: true
    workspaces:
      - packages/cli
      - packages/sdk
  ```

- [ ] Use `monorepo-release.yml` workflow instead of `release.yml`

## Step 5: Configure GitHub Secrets

### For All Projects

- [ ] Enable GitHub Actions:
  - Go to Settings → Actions
  - Select "Allow all actions and reusable workflows"

### For npm Publishing

- [ ] Generate npm token:
  - https://www.npmjs.com/settings/~/tokens
  - Create "Granular Access Token"
  - Select "Packages: Write" permission

- [ ] Add GitHub secret `NPM_TOKEN`:
  - Settings → Secrets and variables → Actions
  - Click "New repository secret"
  - Name: `NPM_TOKEN`
  - Value: (paste npm token)

### For Docker Publishing

- [ ] Generate GitHub personal token (if using ghcr.io):
  - GitHub Settings → Developer settings → Personal access tokens
  - Create "Tokens (classic)"
  - Select "write:packages"

- [ ] Add GitHub secret `GHCR_TOKEN` (optional, GITHUB_TOKEN is automatic):
  - Settings → Secrets and variables → Actions
  - Create new secret

### For Chrome Web Store

- [ ] Generate Chrome Web Store API credentials
- [ ] Add GitHub secrets:
  - [ ] `CHROME_STORE_CLIENT_ID`
  - [ ] `CHROME_STORE_CLIENT_SECRET`
  - [ ] `CHROME_EXTENSION_ID`

### For Slack Notifications (Optional)

- [ ] Create Slack webhook: https://api.slack.com/messaging/webhooks
- [ ] Add GitHub secret `SLACK_WEBHOOK_URL`

## Step 6: Set Git Configuration

- [ ] Configure git user (if not already set):
  ```bash
  git config user.name "Your Name"
  git config user.email "your.email@example.com"
  ```

## Step 7: Test Setup

- [ ] Run preparation checklist:
  ```bash
  bash scripts/prepare-release.sh
  ```

- [ ] Validate conventional commits:
  ```bash
  bash scripts/validate-conventional-commits.sh
  ```

- [ ] Create test commit with commitizen:
  ```bash
  git commit --allow-empty
  # Follow interactive prompt
  ```

- [ ] Test changelog generation (dry-run):
  ```bash
  node scripts/generate-changelog.js --dry-run
  ```

## Step 8: First Release

- [ ] Ensure on `main` branch:
  ```bash
  git checkout main
  git pull origin main
  ```

- [ ] Verify clean working directory:
  ```bash
  git status
  ```

- [ ] Make test commits (if needed):
  ```bash
  # Follow conventional commit format
  git commit -m "feat: add test feature"
  git commit -m "fix: resolve test issue"
  ```

- [ ] Create first release:
  ```bash
  npm run release:minor  # or patch, major as appropriate
  ```

- [ ] Review generated files:
  ```bash
  # Check version updated
  cat package.json | grep version
  
  # Check changelog created
  cat CHANGELOG.md
  
  # Check tag created
  git log --oneline -3
  git tag -l
  ```

- [ ] If satisfied, push:
  ```bash
  git push origin main --follow-tags
  ```

- [ ] If not satisfied, reset:
  ```bash
  git reset --hard HEAD~1
  git tag -d v1.0.0  # Replace with actual tag
  git push origin :refs/tags/v1.0.0  # Delete remote tag
  ```

## Step 9: Verify Automated Workflow

- [ ] Watch GitHub Actions:
  - Go to Actions tab
  - Monitor release workflow execution
  - Wait for completion (5-10 minutes)

- [ ] Verify package published:
  - [ ] npm: https://npmjs.com/package/YOUR_PACKAGE_NAME
  - [ ] Docker: Registry dashboard
  - [ ] GitHub Release: https://github.com/YOUR_ORG/YOUR_REPO/releases

- [ ] Check GitHub Release created:
  - Verify changelog included
  - Verify artifacts uploaded (if applicable)

## Step 10: Documentation

- [ ] Add to project README:
  ```markdown
  ## Release Process
  
  This project uses standardized release workflows.
  
  ### Quick Start
  
  1. Make commits following conventional commit format
  2. Create release: `npm run release`
  3. Push: `git push origin main --follow-tags`
  
  See [RELEASE_WORKFLOWS.md](./RELEASE_WORKFLOWS.md) for details.
  ```

- [ ] Document any project-specific release steps
- [ ] Add CONTRIBUTING.md section on commits
- [ ] Document any custom workflows

## Step 11: Team Communication

- [ ] Share release process documentation with team
- [ ] Document commit message conventions
- [ ] Explain how to use `npm run commit`
- [ ] Point to SETUP_GUIDE.md for new developers

## Step 12: Ongoing Maintenance

- [ ] Review and update workflows quarterly
- [ ] Monitor GitHub Actions execution logs
- [ ] Keep dependencies updated
- [ ] Test pre-release workflow regularly
- [ ] Collect team feedback

## Optional Enhancements

- [ ] Enable commit message GPG signing:
  - [ ] Generate GPG key
  - [ ] Configure git: `git config commit.gpgsign true`
  - [ ] Update workflows to verify signatures

- [ ] Add release notes template

- [ ] Add automatic version bumping in CI

- [ ] Configure Slack/Discord notifications

- [ ] Add Docker buildx caching

- [ ] Set up multi-platform Docker builds

- [ ] Configure branch protections requiring status checks

- [ ] Add automatic release cleanup

- [ ] Set up release approval gates

## Troubleshooting During Setup

### Issue: Husky hooks not running

**Solution**:
```bash
npm install  # Reinstall dependencies
npx husky install
chmod +x .husky/*
```

### Issue: npm publish fails with "403 Forbidden"

**Solution**:
1. Check npm token is set: `cat ~/.npmrc`
2. Regenerate token at npmjs.com
3. Update GitHub secret `NPM_TOKEN`
4. Ensure package.json version is unique

### Issue: GitHub Actions not triggering

**Solution**:
1. Verify workflow files in `.github/workflows/`
2. Check YAML syntax (valid indentation)
3. Push changes to repository
4. Wait 2-3 minutes for GitHub to detect

### Issue: Commitizen not prompting

**Solution**:
```bash
npx husky add .husky/prepare-commit-msg 'exec < /dev/tty && npx cz --hook || true'
```

## Completion Checklist

- [ ] All dependencies installed
- [ ] All workflows copied and configured
- [ ] Git configured properly
- [ ] GitHub secrets added
- [ ] First release successful
- [ ] Automated workflow verified
- [ ] Team documentation complete
- [ ] Team trained on process

## Post-Implementation

### Week 1-2: Monitor

- [ ] Watch for any workflow failures
- [ ] Verify npm/Docker/etc. publishing works
- [ ] Collect team feedback
- [ ] Fix any issues found

### Month 1: Optimize

- [ ] Review workflow execution times
- [ ] Optimize caching strategies
- [ ] Fine-tune notifications
- [ ] Document lessons learned

### Ongoing: Maintain

- [ ] Keep dependencies updated
- [ ] Review new GitHub Actions features
- [ ] Collect team feedback quarterly
- [ ] Update documentation as needed

---

**Total estimated time**: 30-60 minutes for setup
**Team training time**: 15-30 minutes

Questions? See [RELEASE_WORKFLOWS.md](./RELEASE_WORKFLOWS.md) or [SETUP_GUIDE.md](./SETUP_GUIDE.md)
