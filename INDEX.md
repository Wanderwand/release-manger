# Standardized Release Workflows - Complete Index

Welcome to the standardized release workflows repository. This is a comprehensive system for managing releases across different TypeScript/JavaScript project types.

## 📑 Documentation Index

### For Getting Started

1. **[README.md](./README.md)** ⭐ START HERE
   - Quick overview of what's included
   - Quick start guide (5 minutes)
   - Feature list
   - Usage examples

2. **[SETUP_GUIDE.md](./SETUP_GUIDE.md)** - Step-by-step Setup
   - Choose your project type
   - Installation instructions
   - GitHub configuration
   - First release walkthrough
   - Troubleshooting setup issues

3. **[CHECKLIST.md](./CHECKLIST.md)** - Implementation Checklist
   - Checkbox-based setup guide
   - Verification steps
   - Progress tracking
   - Quick reference

### For Deep Dives

4. **[RELEASE_WORKFLOWS.md](./RELEASE_WORKFLOWS.md)** - Complete Reference
   - All release types explained (npm, Docker, Chrome Extension, etc.)
   - Core concepts (semantic versioning, conventional commits)
   - Git integration details
   - GitHub Actions workflow templates
   - Monorepo support
   - Advanced troubleshooting

## 📁 Repository Structure

```
.
├── README.md                          # Quick start & overview
├── SETUP_GUIDE.md                     # Step-by-step setup instructions
├── RELEASE_WORKFLOWS.md               # Complete reference guide
├── CHECKLIST.md                       # Implementation checklist
├── INDEX.md                           # This file
├── .gitignore                         # Git ignore patterns
├── .github/
│   ├── release-config.example.yml     # Configuration template
│   └── workflows/
│       ├── release.yml                # Auto-publish on tag
│       ├── manual-release.yml         # Manual release workflow
│       ├── docker-release.yml         # Docker image release
│       ├── chrome-extension-release.yml # Chrome extension
│       ├── pre-release-validation.yml # Commit validation
│       └── monorepo-release.yml       # Monorepo support
├── scripts/
│   ├── prepare-release.sh             # Pre-release checklist
│   ├── validate-conventional-commits.sh # Commit validation
│   └── generate-changelog.js          # Changelog generation
└── examples/
    ├── package.json.example           # Example npm config
    ├── .commitlintrc.json             # Commit lint config
    ├── .standard-versionrc.json       # Release config
    ├── .eslintrc.json                 # ESLint config
    ├── jest.config.js                 # Jest config
    └── tsconfig.json                  # TypeScript config
```

## 🚀 Quick Navigation

### I want to...

#### Get started quickly
→ Read [README.md](./README.md) (10 min)
→ Follow [SETUP_GUIDE.md](./SETUP_GUIDE.md) (30 min)
→ Create first release (10 min)

#### Understand release concepts
→ Read [RELEASE_WORKFLOWS.md](./RELEASE_WORKFLOWS.md) - Core Concepts section

#### Release npm packages
→ [SETUP_GUIDE.md - Choose Your Release Type](./SETUP_GUIDE.md#choose-your-release-type)
→ Follow npm package section
→ Use `manual-release.yml` or `release.yml` workflow

#### Release Docker images
→ [SETUP_GUIDE.md - For Docker Image](./SETUP_GUIDE.md#for-docker-image)
→ Configure GitHub secrets
→ Use `docker-release.yml` workflow

#### Release Chrome extensions
→ [SETUP_GUIDE.md - For Chrome Extension](./SETUP_GUIDE.md#for-chrome-extension)
→ Configure Chrome Web Store API
→ Use `chrome-extension-release.yml` workflow

#### Work with monorepo
→ [RELEASE_WORKFLOWS.md - Monorepo Support](./RELEASE_WORKFLOWS.md#monorepo-support)
→ [SETUP_GUIDE.md - For Monorepo](./SETUP_GUIDE.md#for-monorepo)
→ Use `monorepo-release.yml` workflow

#### Fix a problem
→ [RELEASE_WORKFLOWS.md - Troubleshooting](./RELEASE_WORKFLOWS.md#troubleshooting)
→ Or [SETUP_GUIDE.md - Troubleshooting Setup Issues](./SETUP_GUIDE.md#troubleshooting-setup-issues)

## 📋 File Purpose Guide

### Documentation Files

| File | Purpose | Audience | Time |
|------|---------|----------|------|
| README.md | Overview & quick start | Everyone | 10 min |
| SETUP_GUIDE.md | Step-by-step setup | Implementers | 45 min |
| RELEASE_WORKFLOWS.md | Complete reference | Advanced users | 60 min |
| CHECKLIST.md | Implementation verification | Implementers | 30 min |
| INDEX.md | This navigation guide | Everyone | 5 min |

### Workflow Files

| Workflow | When to Use | Trigger | Result |
|----------|------------|---------|--------|
| `release.yml` | npm packages | Tag push | Auto-publish |
| `manual-release.yml` | Any project | Manual dispatch | Full release |
| `docker-release.yml` | Docker images | Tag push | Push image |
| `chrome-extension-release.yml` | Extensions | Tag push | Package & release |
| `pre-release-validation.yml` | Quality gate | PR & push | Validation report |
| `monorepo-release.yml` | Monorepos | Manual dispatch | Per-package release |

### Script Files

| Script | Purpose | Usage |
|--------|---------|-------|
| `prepare-release.sh` | Pre-release checklist | `bash scripts/prepare-release.sh` |
| `validate-conventional-commits.sh` | Verify commit format | `bash scripts/validate-conventional-commits.sh` |
| `generate-changelog.js` | Generate changelog | `node scripts/generate-changelog.js` |

### Configuration Examples

| File | Used For |
|------|----------|
| `package.json.example` | npm project setup |
| `.commitlintrc.json` | Commit message validation |
| `.standard-versionrc.json` | Version & changelog config |
| `.eslintrc.json` | Code linting |
| `jest.config.js` | Testing configuration |
| `tsconfig.json` | TypeScript compilation |

## 🎯 Implementation Path

### Path A: Quick Setup (Fastest - 45 min)

1. Read [README.md](./README.md) - 10 min
2. Run setup from [SETUP_GUIDE.md](./SETUP_GUIDE.md) - 30 min
3. Create first release - 5 min

### Path B: Thorough Setup (Best - 90 min)

1. Read [README.md](./README.md) - 10 min
2. Read [RELEASE_WORKFLOWS.md](./RELEASE_WORKFLOWS.md) - 30 min
3. Follow [CHECKLIST.md](./CHECKLIST.md) - 40 min
4. Create first release - 10 min

### Path C: Detailed Implementation (Complete - 2 hours)

1. Read all documentation - 45 min
2. Study [RELEASE_WORKFLOWS.md](./RELEASE_WORKFLOWS.md) in depth - 30 min
3. Go through [CHECKLIST.md](./CHECKLIST.md) step-by-step - 30 min
4. Create test release - 15 min
5. Review and customize for your needs - 20 min

## 🔑 Key Concepts

### Semantic Versioning
Format: `MAJOR.MINOR.PATCH`
- `1.0.0` → `2.0.0` = Breaking changes (MAJOR)
- `1.0.0` → `1.1.0` = New features (MINOR)
- `1.0.0` → `1.0.1` = Bug fixes (PATCH)

### Conventional Commits
Format: `type(scope): message`
- `feat: add login` → suggests MINOR bump
- `fix: resolve bug` → suggests PATCH bump
- `BREAKING CHANGE: remove API` → suggests MAJOR bump

### Release Process
```
Code → Conventional Commits → Release Tag → Workflow → Publish
```

## ✅ Quality Assurance

Each workflow includes:

- ✅ Automatic version detection
- ✅ Changelog generation
- ✅ Git tagging
- ✅ Tests & linting
- ✅ Publishing
- ✅ Release notes

## 🔧 Customization

### Add Your Workflow

1. Copy `examples/` configuration
2. Edit `.github/release-config.yml`
3. Modify workflow YAML files as needed
4. Test locally with scripts first
5. Enable in GitHub Actions

### Add Your Deployment Target

1. Create new workflow in `.github/workflows/`
2. Copy structure from existing workflow
3. Customize steps for your target
4. Update `.github/release-config.yml`
5. Test and verify

## 📚 Additional Resources

### External References

- [Semantic Versioning](https://semver.org/)
- [Conventional Commits](https://www.conventionalcommits.org/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [standard-version](https://github.com/conventional-changelog/standard-version)
- [commitizen](https://github.com/commitizen/cz-cli)

### Tool Documentation

- [npm Publishing](https://docs.npmjs.com/creating-and-publishing-unscoped-public-packages)
- [Docker Build & Push](https://docs.docker.com/build/)
- [Chrome Web Store API](https://developer.chrome.com/docs/webstore/api_index/)
- [GitHub Releases API](https://docs.github.com/en/rest/releases)

## 🤝 Support & Troubleshooting

### Common Issues

**Issue**: Workflow not triggering
- See [SETUP_GUIDE.md - Troubleshooting](./SETUP_GUIDE.md#troubleshooting-setup-issues)

**Issue**: npm publish fails
- See [RELEASE_WORKFLOWS.md - Troubleshooting](./RELEASE_WORKFLOWS.md#troubleshooting)

**Issue**: Commits not detected
- Use `npm run commit` for interactive prompts
- Verify format with scripts

### Get Help

1. Check [RELEASE_WORKFLOWS.md](./RELEASE_WORKFLOWS.md) troubleshooting section
2. Review GitHub Actions logs for specific errors
3. Consult [SETUP_GUIDE.md](./SETUP_GUIDE.md) for setup issues
4. Check example configurations in `examples/`

## 📝 Checklists

### Before You Start
- [ ] Decided on release target (npm, Docker, etc.)
- [ ] Have npm account (for npm) or Docker Hub (for Docker)
- [ ] Have Git configured locally
- [ ] Have GitHub access with admin rights

### During Setup
- [ ] Dependencies installed
- [ ] Hooks configured
- [ ] Scripts tested
- [ ] Secrets added to GitHub
- [ ] First release successful

### After Setup
- [ ] Document your process
- [ ] Train your team
- [ ] Test workflows
- [ ] Monitor first few releases

## 🎓 Learning Path

### Beginner
1. [README.md](./README.md)
2. [SETUP_GUIDE.md](./SETUP_GUIDE.md)
3. First release

### Intermediate
1. [RELEASE_WORKFLOWS.md](./RELEASE_WORKFLOWS.md) - Core Concepts
2. Customize configuration
3. Create custom workflows

### Advanced
1. [RELEASE_WORKFLOWS.md](./RELEASE_WORKFLOWS.md) - All sections
2. Monorepo implementation
3. Custom deployment targets

## 📊 Feature Matrix

| Feature | npm | Docker | Extension | GitHub |
|---------|-----|--------|-----------|--------|
| Auto-versioning | ✅ | ✅ | ✅ | ✅ |
| Changelog | ✅ | ✅ | ✅ | ✅ |
| Git tagging | ✅ | ✅ | ✅ | ✅ |
| Auto-publish | ✅ | ✅ | ⚠️ | ✅ |
| Monorepo | ✅ | ✅ | ⚠️ | ✅ |
| Pre-release | ✅ | ✅ | ✅ | ✅ |
| Multi-platform | ⚠️ | ✅ | - | ✅ |

## 🚀 Next Steps

1. **Start Here**: Read [README.md](./README.md)
2. **Follow Guide**: Go through [SETUP_GUIDE.md](./SETUP_GUIDE.md)
3. **Verify Setup**: Use [CHECKLIST.md](./CHECKLIST.md)
4. **Create Release**: Follow [SETUP_GUIDE.md - First Release](./SETUP_GUIDE.md#first-release)
5. **Reference**: Use [RELEASE_WORKFLOWS.md](./RELEASE_WORKFLOWS.md) as needed

---

**Questions?** Start with [README.md](./README.md)

**Ready to implement?** Go to [SETUP_GUIDE.md](./SETUP_GUIDE.md)

**Need reference?** Check [RELEASE_WORKFLOWS.md](./RELEASE_WORKFLOWS.md)

**Tracking progress?** Use [CHECKLIST.md](./CHECKLIST.md)
