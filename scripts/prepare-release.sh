#!/bin/bash

# Prepare Release Script
# Validates repository state before release and performs pre-release checks
# 
# Usage: ./scripts/prepare-release.sh [--auto] [--type major|minor|patch|prerelease]
#
# Options:
#   --auto    Automatically detect version bump from commits
#   --type    Specify release type (default: patch)

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Default values
AUTO_DETECT=false
RELEASE_TYPE="patch"

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --auto)
      AUTO_DETECT=true
      shift
      ;;
    --type)
      RELEASE_TYPE="$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

echo -e "${BLUE}═══════════════════════════════════════${NC}"
echo -e "${BLUE}  Release Preparation Checklist${NC}"
echo -e "${BLUE}═══════════════════════════════════════${NC}"
echo ""

# Check if we're in a git repository
echo -n "Checking git repository... "
if git rev-parse --git-dir > /dev/null 2>&1; then
  echo -e "${GREEN}✓${NC}"
else
  echo -e "${RED}✗ Not in a git repository${NC}"
  exit 1
fi

# Check working directory is clean
echo -n "Checking working directory... "
if [ -z "$(git status --porcelain)" ]; then
  echo -e "${GREEN}✓${NC}"
else
  echo -e "${RED}✗ Working directory has uncommitted changes${NC}"
  git status --short
  exit 1
fi

# Check on main branch
echo -n "Checking branch (main)... "
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [ "$CURRENT_BRANCH" = "main" ] || [ "$CURRENT_BRANCH" = "master" ]; then
  echo -e "${GREEN}✓${NC}"
else
  echo -e "${YELLOW}⚠${NC} Currently on branch: $CURRENT_BRANCH (expected: main/master)"
  read -p "Continue anyway? (y/N) " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
  fi
fi

# Check if up to date with remote
echo -n "Checking remote synchronization... "
REMOTE_BRANCH="origin/${CURRENT_BRANCH}"
if git fetch origin > /dev/null 2>&1; then
  if [ "$(git rev-list --count HEAD..@{u})" -eq 0 ]; then
    echo -e "${GREEN}✓${NC}"
  else
    echo -e "${YELLOW}⚠${NC} Local branch is behind remote"
    read -p "Pull latest changes? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      git pull origin "$CURRENT_BRANCH"
    fi
  fi
else
  echo -e "${YELLOW}⚠${NC} Could not fetch from remote"
fi

# Check for required tools
echo -n "Checking for npm... "
if command -v npm &> /dev/null; then
  NPM_VERSION=$(npm --version)
  echo -e "${GREEN}✓${NC} (v${NPM_VERSION})"
else
  echo -e "${RED}✗ npm not found${NC}"
  exit 1
fi

# Check for git
echo -n "Checking for git... "
if command -v git &> /dev/null; then
  GIT_VERSION=$(git --version | cut -d' ' -f3)
  echo -e "${GREEN}✓${NC} (v${GIT_VERSION})"
else
  echo -e "${RED}✗ git not found${NC}"
  exit 1
fi

# Check package.json exists
echo -n "Checking package.json... "
if [ -f "$PROJECT_DIR/package.json" ]; then
  CURRENT_VERSION=$(node -p "require('$PROJECT_DIR/package.json').version")
  echo -e "${GREEN}✓${NC} (v${CURRENT_VERSION})"
else
  echo -e "${RED}✗ package.json not found${NC}"
  exit 1
fi

# Check for required dev dependencies
echo -n "Checking for standard-version... "
if npm ls standard-version > /dev/null 2>&1; then
  echo -e "${GREEN}✓${NC}"
else
  echo -e "${YELLOW}⚠${NC} Not installed"
  read -p "Install now? (y/N) " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    npm install --save-dev standard-version
  fi
fi

# Check git configuration
echo -n "Checking git user configuration... "
GIT_USER=$(git config user.name)
GIT_EMAIL=$(git config user.email)
if [ -z "$GIT_USER" ] || [ -z "$GIT_EMAIL" ]; then
  echo -e "${YELLOW}⚠${NC} Not configured"
  read -p "Configure now? (y/N) " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    read -p "Git name: " GIT_USER
    read -p "Git email: " GIT_EMAIL
    git config user.name "$GIT_USER"
    git config user.email "$GIT_EMAIL"
  fi
else
  echo -e "${GREEN}✓${NC} ($GIT_USER <$GIT_EMAIL>)"
fi

# Check npm token for publishing
echo -n "Checking npm authentication... "
if npm whoami > /dev/null 2>&1; then
  NPM_USER=$(npm whoami)
  echo -e "${GREEN}✓${NC} (logged in as: $NPM_USER)"
else
  echo -e "${YELLOW}⚠${NC} Not authenticated"
  read -p "Run 'npm login'? (y/N) " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    npm login
  fi
fi

# Summary
echo ""
echo -e "${BLUE}═══════════════════════════════════════${NC}"
echo -e "${BLUE}  Summary${NC}"
echo -e "${BLUE}═══════════════════════════════════════${NC}"
echo ""
echo "Current version: ${CURRENT_VERSION}"
echo "Current branch: ${CURRENT_BRANCH}"
echo "Release type: ${RELEASE_TYPE}"
echo ""

# Auto-detect version if requested
if [ "$AUTO_DETECT" = true ]; then
  echo "Detecting version from commit history..."
  
  # Simple detection based on conventional commits
  COMMIT_HISTORY=$(git log "$(git describe --tags --abbrev=0)..HEAD" --oneline 2>/dev/null || git log --oneline -20)
  
  if echo "$COMMIT_HISTORY" | grep -q "^.*BREAKING CHANGE"; then
    RELEASE_TYPE="major"
    echo -e "${YELLOW}Detected BREAKING CHANGE - setting to: major${NC}"
  elif echo "$COMMIT_HISTORY" | grep -q "^.*feat"; then
    RELEASE_TYPE="minor"
    echo -e "${YELLOW}Detected new features - setting to: minor${NC}"
  else
    RELEASE_TYPE="patch"
    echo -e "${YELLOW}Detected bug fixes - setting to: patch${NC}"
  fi
fi

echo -e "${GREEN}✓ All checks passed!${NC}"
echo ""
echo "Next steps:"
echo "  1. Review commit history: git log --oneline -10"
echo "  2. Update version: npm run release"
echo "  3. Review changes and changelog"
echo "  4. Push: git push origin ${CURRENT_BRANCH} --follow-tags"
echo ""
