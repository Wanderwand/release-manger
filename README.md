# Standardized Release Workflows for TypeScript Projects

Complete, production-ready release workflow system for TypeScript/JavaScript projects with support for multiple deployment targets.

## 📋 Overview

This repository contains standardized, reusable workflows and documentation for managing releases across different project types:

- 📦 **npm Packages** - Publish to npm registry
- 🐳 **Docker Images** - Push to Docker registries
- 🎨 **Chrome Extensions** - Release to Chrome Web Store
- 🚀 **GitHub Releases** - Create GitHub releases with artifacts
- 🌐 **Static Sites** - Deploy to GitHub Pages
- 📱 **Binaries** - Release compiled executables

## ✨ Features

### Automated Version Management
- Semantic versioning (major.minor.patch)
- Automatic version detection from conventional commits
- Pre-release support (alpha, beta, rc, etc.)

### Changelog Generation
- Automatic changelog from commit messages
- Grouped by type (Features, Bug Fixes, Breaking Changes)
- Follows conventional commit standards

### Git Integration
- Automatic tagging on release
- Scoped tags for monorepo support
- Sign commits and tags (GPG support)

### CI/CD Workflows
- GitHub Actions workflows for each release type
- Manual release trigger option
- Automated publishing on tag push
- Multi-platform builds (Linux, macOS, Windows, ARM)

### Quality Assurance
- Pre-release validation checks
- Conventional commit enforcement
- Automated testing before release
- Lint and type checking

### Flexibility
- Configuration-driven approach
- Support for single repos and monorepos
- Customizable for different project types
- Easy integration with existing projects

## 🚀 Quick Start

### 1. Add Release Workflows to Your Project

```bash
# Copy workflows to your project
cp -r .github/workflows/* your-project/.github/workflows/

# Copy helper scripts
cp -r scripts/* your-project/scripts/

# Copy configuration template
cp .github/release-config.example.yml your-project/.github/release-config.yml
```

### 2. Install Release Tools

```bash
npm install --save-dev \
  commitizen \
  cz-conventional-changelog \
  standard-version \
  @commitlint/cli \
  @commitlint/config-conventional \
  husky
```

### 3. Initialize Husky

```bash
npx husky install
npx husky add .husky/commit-msg 'npx --no-- commitlint --edit "$1"'
npx husky add .husky/prepare-commit-msg 'exec < /dev/tty && npx cz --hook || true'
```

### 4. Add npm Scripts

Add to `package.json`:

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

### 5. Create First Release

```bash
# Validate setup
bash scripts/prepare-release.sh

# Create release
npm run release:minor

# Review changes
git log -1
cat CHANGELOG.md

# Push with tags
git push origin main --follow-tags
```

See [SETUP_GUIDE.md](./SETUP_GUIDE.md) for detailed setup instructions.

## 📚 Documentation

### Main Documentation

- **[RELEASE_WORKFLOWS.md](./RELEASE_WORKFLOWS.md)** - Complete guide to all release workflows
  - Release type details (npm, Docker, Chrome Extension, etc.)
  - Core concepts (semver, conventional commits, changelog)
  - GitHub Actions workflow templates
  - Troubleshooting guide

- **[SETUP_GUIDE.md](./SETUP_GUIDE.md)** - Step-by-step setup instructions
  - Project-specific setup for different release types
  - GitHub Actions configuration
  - First release walkthrough
  - Ongoing usage patterns

### Example Files

The `examples/` directory contains template configuration files:

- `package.json.example` - Package.json with release scripts
- `.commitlintrc.json` - Commitlint configuration
- `.standard-versionrc.json` - Standard-version configuration
- `jest.config.js` - Jest testing configuration
- `.eslintrc.json` - ESLint configuration
- `tsconfig.json` - TypeScript configuration

Copy and customize these for your project.

## 🔧 Available Workflows

### GitHub Actions Workflows

Located in `.github/workflows/`:

#### `release.yml`
Automatically publishes to npm when a git tag is pushed.

**Trigger**: Push `v*` tag (e.g., `git tag v1.2.3 && git push origin v1.2.3`)

**Steps**:
1. Checkout code
2. Install dependencies
3. Run tests
4. Build project
5. Publish to npm
6. Create GitHub Release

#### `manual-release.yml`
Manual release workflow with version selection.

**Trigger**: GitHub Actions → Manual Release → Run workflow

**Options**:
- `major` - Breaking changes
- `minor` - New features
- `patch` - Bug fixes
- `prerelease` - RC/alpha/beta

#### `docker-release.yml`
Build and push Docker image to registry.

**Trigger**: Push `v*` tag

**Features**:
- Multi-platform builds (amd64, arm64)
- Tags with version and "latest"
- Automated caching

#### `chrome-extension-release.yml`
Package and release Chrome extension.

**Trigger**: Push `v*` tag

**Features**:
- Builds extension
- Generates checksums
- Creates GitHub Release with artifact

#### `pre-release-validation.yml`
Validates commits follow conventional format on every PR.

**Trigger**: Pull request, push to main

**Checks**:
- Conventional commit format
- Code linting
- Type checking
- Tests

#### `monorepo-release.yml`
Release individual packages in monorepo.

**Trigger**: Manual dispatch

**Features**:
- Release single or all packages
- Per-package versioning
- Scoped tagging

## 📝 Helper Scripts

Located in `scripts/`:

### `prepare-release.sh`
Pre-release checklist and validation.

```bash
bash scripts/prepare-release.sh [--auto] [--type major|minor|patch]
```

Checks:
- Git repository state
- Working directory cleanliness
- Branch is up to date
- Required tools installed
- npm authentication

### `validate-conventional-commits.sh`
Validate commits follow conventional format.

```bash
bash scripts/validate-conventional-commits.sh [--since TAG]
```

### `generate-changelog.js`
Generate or update CHANGELOG.md.

```bash
node scripts/generate-changelog.js [--version VERSION] [--dry-run]
```

## 🔑 Configuration

### Basic Configuration

Create `.github/release-config.yml`:

```yaml
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
```

See `.github/release-config.example.yml` for all options.

## 🔐 GitHub Secrets

Configure based on your deployment needs:

### For npm Publishing

1. Generate npm token: https://www.npmjs.com/settings/~/tokens
2. Add to repository secrets as `NPM_TOKEN`

### For Docker Registry

1. Create personal access token with "Packages: read and write"
2. Add as `GHCR_TOKEN` (optional - GITHUB_TOKEN is automatic)

### For Chrome Web Store

1. Create API credentials in Chrome Web Store
2. Add secrets:
   - `CHROME_STORE_CLIENT_ID`
   - `CHROME_STORE_CLIENT_SECRET`
   - `CHROME_EXTENSION_ID`

## 📖 Usage Examples

### Example 1: NPM Package Release

```bash
# 1. Make commits with conventional format
git commit -m "feat: add new API endpoint"
git commit -m "fix: resolve memory leak"

# 2. Create release
npm run release:minor

# 3. Push
git push origin main --follow-tags

# Workflow automatically:
# ✓ Updates package.json version to 1.1.0
# ✓ Generates CHANGELOG.md entry
# ✓ Creates git tag v1.1.0
# ✓ Publishes to npm
# ✓ Creates GitHub Release
```

### Example 2: Docker Image Release

```bash
# Create and push release
npm run release:patch
git push origin main --follow-tags

# Workflow automatically:
# ✓ Builds Docker image with version tags
# ✓ Pushes to ghcr.io
# ✓ Creates GitHub Release
```

### Example 3: Monorepo Release

1. Go to GitHub Actions → Monorepo Release
2. Select package: `packages/cli`
3. Select type: `minor`
4. Click "Run workflow"
5. Workflow handles:
   ✓ Updates package version
   ✓ Creates scoped tag: `@package-name@1.2.3`
   ✓ Publishes to npm
   ✓ Creates GitHub Release

## 🛠️ Customization

### Add Custom Release Type

Edit workflow files to add new deployment target:

```yaml
deployments:
  - name: my-custom-target
    enabled: true
    # Add custom steps
```

### Customize Version Strategy

Edit `.standard-versionrc.json`:

```json
{
  "types": [
    {"type": "feat", "section": "Features"},
    {"type": "fix", "section": "Bug Fixes"}
  ],
  "commitUrlFormat": "https://your-domain/commits/{{hash}}"
}
```

### Add Custom Pre-release Suffix

```json
{
  "prerelease": "alpha"
}
```

## 📱 Release Type Examples

### npm Package
```
Versioning: 1.2.3
Tag format: v1.2.3
Registry: npmjs.com
Published: Automatic on tag
```

### Docker Image
```
Versioning: 1.2.3
Tags: latest, 1.2, 1.2.3
Registry: ghcr.io
Platforms: linux/amd64, linux/arm64
```

### Chrome Extension
```
Versioning: manifest.json version
Tag format: v1.2.3
Target: Chrome Web Store
Artifact: chrome-extension-1.2.3.zip
```

### GitHub Release
```
Versioning: 1.2.3 or calendar-based
Artifacts: Binary files, checksums
Format: Markdown with release notes
Prerelease: Optional
```

## 🔄 Workflow Comparison

| Workflow | Trigger | Target | Auto-publish |
|----------|---------|--------|--------------|
| `release.yml` | Tag push | npm, GitHub | ✅ Yes |
| `manual-release.yml` | Manual | npm, GitHub | ✅ Yes |
| `docker-release.yml` | Tag push | Docker | ✅ Yes |
| `chrome-extension-release.yml` | Tag push | Chrome Store | ⚠️ Manual |
| `monorepo-release.yml` | Manual | npm | ✅ Yes |

## 🐛 Troubleshooting

### Workflow Not Triggering
- Check workflow file exists in `.github/workflows/`
- Verify branch is `main` or configured branch
- Check workflow syntax (valid YAML)
- Wait 1-2 minutes for GitHub to pick up changes

### npm Publish Fails
- Verify `NPM_TOKEN` secret is set
- Check token has "Packages: Write" permission
- Ensure package.json version is unique
- Check if package is scoped (requires different config)

### Conventional Commits Not Detected
- Use `npm run commit` for interactive prompt
- Or manually format: `type(scope): message`
- Run `bash scripts/validate-conventional-commits.sh` to check

### Changelog Not Generated
- Ensure commits follow conventional format
- Check `CHANGELOG.md` is in `.gitignore` if auto-generated
- Run `node scripts/generate-changelog.js --dry-run` to test

See [RELEASE_WORKFLOWS.md#Troubleshooting](./RELEASE_WORKFLOWS.md#troubleshooting) for more solutions.

## 🤝 Contributing

To improve these workflows:

1. Test changes locally first
2. Document any new features
3. Update examples/ templates
4. Ensure backward compatibility

## 📄 License

MIT - Feel free to use and customize for your projects.

## 📞 Support

For issues or questions:

1. Check [RELEASE_WORKFLOWS.md](./RELEASE_WORKFLOWS.md#troubleshooting)
2. Review [SETUP_GUIDE.md](./SETUP_GUIDE.md)
3. Check GitHub Actions logs for specific errors
4. Review example configurations in `examples/`

## 🎯 Next Steps

1. ✅ Copy workflows to your project
2. ✅ Install dependencies
3. ✅ Run setup checklist
4. ✅ Create first release
5. ✅ Configure GitHub secrets
6. ✅ Test automated workflows

See [SETUP_GUIDE.md](./SETUP_GUIDE.md) to get started!
