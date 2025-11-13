#!/bin/bash

# Validate Conventional Commits
# Checks if commits follow conventional commit format
# Useful for validating commit history before release
#
# Usage: ./scripts/validate-conventional-commits.sh [--since TAG]

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SINCE="origin/main"

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --since)
      SINCE="$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

echo -e "${BLUE}Validating Conventional Commits${NC}"
echo -e "${BLUE}Range: $SINCE..HEAD${NC}"
echo ""

# Get commit history
COMMITS=$(git log "$SINCE"..HEAD --pretty=format:"%H %s" 2>/dev/null || git log --pretty=format:"%H %s" -20)

if [ -z "$COMMITS" ]; then
  echo -e "${YELLOW}No commits found in range${NC}"
  exit 0
fi

# Conventional commit pattern
# Format: type(scope): description
# Types: feat, fix, docs, style, refactor, perf, test, chore, ci, revert
PATTERN="^(feat|fix|docs|style|refactor|perf|test|chore|ci|revert)(\(.+\))?: .{1,}"

VALID_COUNT=0
INVALID_COUNT=0
INVALID_COMMITS=()

while IFS=' ' read -r HASH SUBJECT; do
  if [[ $SUBJECT =~ $PATTERN ]]; then
    echo -e "${GREEN}✓${NC} $HASH $SUBJECT"
    ((VALID_COUNT++))
  else
    echo -e "${RED}✗${NC} $HASH $SUBJECT"
    ((INVALID_COUNT++))
    INVALID_COMMITS+=("$HASH")
  fi
done <<< "$COMMITS"

echo ""
echo -e "${BLUE}Summary${NC}"
echo "Valid commits: ${VALID_COUNT}"
echo "Invalid commits: ${INVALID_COUNT}"

if [ ${INVALID_COUNT} -gt 0 ]; then
  echo ""
  echo -e "${YELLOW}Invalid commits need to be fixed:${NC}"
  for COMMIT in "${INVALID_COMMITS[@]}"; do
    echo "  - $COMMIT"
  done
  echo ""
  echo "To fix: Use 'git rebase -i' or 'git commit --amend'"
  exit 1
fi

echo ""
echo -e "${GREEN}✓ All commits follow conventional commit format!${NC}"
