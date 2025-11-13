#!/usr/bin/env node

/**
 * Generate Changelog from Conventional Commits
 * 
 * This script generates or updates CHANGELOG.md based on conventional commits
 * since the last tag.
 * 
 * Usage: node scripts/generate-changelog.js [--version VERSION] [--dry-run]
 */

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

// Colors for console output
const colors = {
  reset: '\x1b[0m',
  green: '\x1b[32m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
  red: '\x1b[31m',
};

class ChangelogGenerator {
  constructor(options = {}) {
    this.dryRun = options.dryRun || false;
    this.version = options.version || this.detectVersion();
    this.changelogPath = options.changelogPath || 'CHANGELOG.md';
    this.commits = [];
  }

  log(message, color = 'reset') {
    console.log(`${colors[color]}${message}${colors.reset}`);
  }

  detectVersion() {
    try {
      const pkg = JSON.parse(fs.readFileSync('package.json', 'utf8'));
      return pkg.version;
    } catch {
      return '1.0.0';
    }
  }

  getCommitsSinceLastTag() {
    try {
      // Get the last tag
      const lastTag = execSync('git describe --tags --abbrev=0 2>/dev/null || echo ""')
        .toString()
        .trim();

      let range = 'HEAD';
      if (lastTag) {
        range = `${lastTag}..HEAD`;
      } else {
        // If no tags exist, get last 50 commits
        range = 'HEAD~50..HEAD';
      }

      // Get commits in conventional commit format
      const output = execSync(
        `git log ${range} --pretty=format:"%H|%s|%b" --no-merges 2>/dev/null || true`
      )
        .toString()
        .trim();

      if (!output) return [];

      const commits = output.split('\n').map((line) => {
        const [hash, subject, body] = line.split('|');
        return {
          hash: hash.substring(0, 7),
          subject: subject.trim(),
          body: body ? body.trim() : '',
          type: this.getCommitType(subject),
          scope: this.getCommitScope(subject),
          message: this.getCommitMessage(subject),
          breaking: body.includes('BREAKING CHANGE'),
        };
      });

      return commits;
    } catch (error) {
      this.log(`Warning: Could not get commits: ${error.message}`, 'yellow');
      return [];
    }
  }

  getCommitType(subject) {
    const match = subject.match(/^(feat|fix|docs|style|refactor|perf|test|chore|ci|revert)/);
    return match ? match[1] : 'other';
  }

  getCommitScope(subject) {
    const match = subject.match(/^[^(]+\(([^)]+)\)/);
    return match ? match[1] : '';
  }

  getCommitMessage(subject) {
    return subject.replace(/^[^:]+:\s*/, '');
  }

  groupCommits(commits) {
    const groups = {
      'Breaking Changes': [],
      'Features': [],
      'Bug Fixes': [],
      'Performance': [],
      'Documentation': [],
      'Other': [],
    };

    commits.forEach((commit) => {
      if (commit.breaking) {
        groups['Breaking Changes'].push(commit);
      } else if (commit.type === 'feat') {
        groups['Features'].push(commit);
      } else if (commit.type === 'fix') {
        groups['Bug Fixes'].push(commit);
      } else if (commit.type === 'perf') {
        groups['Performance'].push(commit);
      } else if (commit.type === 'docs') {
        groups['Documentation'].push(commit);
      } else {
        groups['Other'].push(commit);
      }
    });

    return Object.entries(groups).filter(([_, commits]) => commits.length > 0);
  }

  formatCommit(commit) {
    const scope = commit.scope ? ` **${commit.scope}**:` : '';
    const link = ` ([${commit.hash}](../../commit/${commit.hash}))`;
    return `- ${commit.message}${scope}${link}`;
  }

  generateEntries(commits) {
    if (commits.length === 0) {
      return '';
    }

    const grouped = this.groupCommits(commits);
    let entries = '';

    grouped.forEach(([section, commits]) => {
      entries += `### ${section}\n\n`;
      commits.forEach((commit) => {
        entries += this.formatCommit(commit) + '\n';
      });
      entries += '\n';
    });

    return entries;
  }

  getDate() {
    const now = new Date();
    const year = now.getFullYear();
    const month = String(now.getMonth() + 1).padStart(2, '0');
    const day = String(now.getDate()).padStart(2, '0');
    return `${year}-${month}-${day}`;
  }

  generateReleaseSection(entries) {
    if (!entries.trim()) {
      return '';
    }

    const date = this.getDate();
    return `## [${this.version}] - ${date}\n\n${entries}\n`;
  }

  readExistingChangelog() {
    try {
      return fs.readFileSync(this.changelogPath, 'utf8');
    } catch {
      return '';
    }
  }

  writeChangelog(content) {
    if (this.dryRun) {
      this.log('DRY RUN: Would write to CHANGELOG.md:', 'yellow');
      console.log(content);
      return;
    }

    fs.writeFileSync(this.changelogPath, content, 'utf8');
  }

  generate() {
    this.log(`\nGenerating changelog for version ${this.version}...`, 'blue');

    // Get commits
    this.log('Fetching commits...', 'blue');
    const commits = this.getCommitsSinceLastTag();

    if (commits.length === 0) {
      this.log('No commits found since last release', 'yellow');
      return;
    }

    this.log(`Found ${commits.length} commits`, 'green');

    // Generate entries
    const entries = this.generateEntries(commits);
    const releaseSection = this.generateReleaseSection(entries);

    // Read existing changelog
    const existingChangelog = this.readExistingChangelog();

    // Combine
    const header = existingChangelog.startsWith('# Changelog')
      ? ''
      : '# Changelog\n\n';
    const newContent = header + releaseSection + existingChangelog;

    // Write
    this.writeChangelog(newContent);

    if (!this.dryRun) {
      this.log(`✓ Changelog updated: ${this.changelogPath}`, 'green');
    }
  }
}

// Main
const args = process.argv.slice(2);
const options = {
  dryRun: args.includes('--dry-run'),
  version: (() => {
    const idx = args.indexOf('--version');
    return idx !== -1 ? args[idx + 1] : undefined;
  })(),
};

const generator = new ChangelogGenerator(options);
generator.generate();
