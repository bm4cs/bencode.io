---
layout: post
draft: false
title: "Claude Code Gems"
slug: "claudecode"
date: "2026-04-10 12:03:00+1000"
lastmod: "2026-04-10 12:03:00+1000"
comments: false
categories:
  - claude
  - claudecode
  - agents
  - ai
---

- [Insight Report](#insight-report)
- [Effort level](#effort-level)
- [Remote Control](#remote-control)
- [Batch tasks](#batch-tasks)
- [Simplify](#simplify)
- [Recurring work (loops)](#recurring-work-loops)
- [Rewind Mode](#rewind-mode)
- [Hooks and Automation](#hooks-and-automation)
- [BTW side questions](#btw-side-questions)
- [Agent Teams and Parallel Work](#agent-teams-and-parallel-work)
- [Danger Mode](#danger-mode)

## Insight Report

Generates a structured report about your codebase and how you've been working with Claude Code. It analyses your conversation history, tool usage patterns, and the types of tasks you've been tackling. Useful for understanding your own workflow patterns — where you spend time, what types of tasks you delegate most, and where friction tends to occur. Think of it as a retrospective on your AI-assisted development habits.

```sh
# Generate an insights report for the current project
/insights

# Example output includes:
# - Session count and duration trends
# - Most-used tools (Edit, Bash, Grep, etc.)
# - Common task categories (bug fixes, features, refactors)
# - Suggestions for workflow improvements
```

## Effort level

Controls reasoning depth on a per-prompt basis. Set `/effort min` for quick trivial questions where you don't need Claude to overthink, or `/effort max` when you're working on something architecturally complex that benefits from deeper analysis. The default sits in the middle. This directly affects response quality vs speed — saving you tokens and time on simple lookups while ensuring thorough reasoning when it matters.

```sh
# Quick lookup — don't overthink it
/effort min
what port does redis default to?

# Deep architectural analysis
/effort max
review our authentication flow and identify potential race conditions

# Reset to default
/effort medium
```

## Remote Control

Lets you control a Claude Code session programmatically from another process or terminal. You can send prompts, receive responses, and orchestrate Claude Code as part of larger automation workflows. This opens the door to building custom tooling on top of Claude Code — trigger it from CI, from scripts, or from other agents. It essentially turns Claude Code into an API you can drive from anywhere on your machine.

```sh
# Start a session and get its ID
claude --session-id my-worker --json

# From another terminal, send a prompt to that session
claude remote send --session my-worker "run the test suite and summarise failures"

# Use in a script — pipe prompts in, get structured JSON out
echo "explain the main function in src/index.ts" | claude --json --session my-worker

# Trigger from CI to auto-fix lint errors
claude -p "fix all eslint errors in src/" --allowedTools Edit,Write
```

## Batch tasks

Batch tasks and maximise parallel operation across worktrees and sub-agents. You give it a high-level instruction and it fans out the work across multiple files or components simultaneously, each in its own isolated git worktree. For example:

> /batch Add error handling to all the python scripts in this directory

Instead of processing files sequentially, it spins up parallel agents that each handle a subset of the work. Massive time saver for repetitive-but-contextual changes across a codebase.

```sh
# Add error handling across all Python scripts
/batch Add error handling to all the python scripts in this directory

# Add docstrings to every exported function
/batch Add JSDoc comments to all exported functions in src/

# Migrate a set of components from class-based to functional
/batch Convert all class components in src/components/ to functional components with hooks
```

## Simplify

Spins up 3 code review agents in parallel, each examining your recent changes through a different lens: duplication (can this reuse existing code?), quality (are there bugs or code smells?), and efficiency (can this be done more simply?). It then consolidates findings and applies fixes. Great to run after completing a feature — it catches the kind of issues that emerge when you've been heads-down building and lose perspective on the bigger picture.

```sh
# After finishing a feature, run simplify to catch what you missed
/simplify

# Example findings it might surface:
# - "formatDate() in utils.ts duplicates dayjs.format() already imported in 3 other files"
# - "the retry loop in fetchData() silently swallows errors — consider logging or re-throwing"
# - "the nested ternary in render() could be a simple lookup table"
```

## Recurring work (loops)

Runs a command or prompt on a recurring interval. For example `/loop 5m /progress` checks your project status every 5 minutes, or you could poll a deployment, watch for CI results, or periodically re-run tests while you're refactoring. Defaults to a 10 minute interval. Turns Claude Code into a lightweight monitoring agent that keeps an eye on things while you focus elsewhere.

```sh
# Re-run tests every 5 minutes while you refactor
/loop 5m run pytest and report any new failures

# Poll a deployment status
/loop 2m check if the staging deploy at https://staging.example.com/health is returning 200

# Periodic code quality check (uses default 10m interval)
/loop run the linter and tell me if any new warnings appeared
```

## Rewind Mode

Lets you step backwards through your conversation and Claude's changes, effectively undoing work to a previous checkpoint. If Claude went down the wrong path — wrong approach, bad refactor, broke something — you can rewind to before that happened rather than trying to manually untangle the mess. It restores both the conversation state and the file changes. Like an undo button for your entire AI-assisted coding session.

```sh
# Claude just broke your auth module with a bad refactor — rewind
# In the Claude Code UI, press Ctrl+R or use:
/rewind

# You'll see a list of checkpoints like:
# [3] Added error handling to api.ts
# [2] Refactored auth middleware    <-- this is where it went wrong
# [1] Initial file reads
# Select checkpoint 1 to restore files and conversation to that point

# Now try a different approach with full context intact
refactor auth middleware but keep the existing session handling
```

## Hooks and Automation

Hooks are shell commands that fire automatically in response to Claude Code events — before/after tool calls, on conversation start, etc. Configured in your `settings.json`, they let you enforce workflows without relying on Claude to remember rules. Examples: auto-format code after every file edit, run linters before commits, block writes to certain directories, or log all tool usage. The key insight is that hooks are executed by the harness, not by Claude — so they're deterministic and can't be accidentally skipped.

```json
// .claude/settings.json
{
  "hooks": {
    "afterEdit": ["prettier --write $CLAUDE_FILE_PATH"],
    "beforeCommit": ["npm run lint", "npm run test -- --bail"],
    "afterWrite": [
      "echo 'File written: $CLAUDE_FILE_PATH' >> /tmp/claude-audit.log"
    ]
  }
}
```

```sh
# Every time Claude edits a file, prettier auto-formats it
# Every commit attempt runs lint + tests first — no skipping
# All file writes get logged for audit
```

## BTW side questions

The "BTW" pattern — asking a quick tangential question mid-task without derailing your current workflow. Claude Code maintains context about what you're working on, so you can ask something like "btw what does this regex do?" or "btw is there a built-in for this?" and get an answer without losing your place. The conversational nature means you don't need to context-switch to a browser or docs — just ask inline and keep going.

```sh
# Mid-refactor, you spot something unfamiliar
> /btw what does the ?= in this regex mean?
# Claude answers (it's a lookahead assertion) and you continue working

# Wondering about a dependency while debugging
> /btw is there a native Node.js alternative to the lodash.debounce were importing?
# Quick answer, no context switch, back to the bug

# Architecture question while implementing
> /btw do we have rate limiting middleware anywhere in this project already?
# Claude greps the codebase, answers, and you avoid reinventing the wheel
```

## Agent Teams and Parallel Work

Claude Code can spawn sub-agents that work in parallel on different aspects of a problem, each in isolated git worktrees so they don't step on each other. You can orchestrate teams of agents — one researching, one implementing, one testing — that coordinate through the main agent. This is the unlock for tackling larger tasks that would be too slow sequentially. Each agent has its own context window and toolset, and results get merged back together.

```sh
# Ask Claude to tackle a large feature — it automatically fans out the work
> Build a REST API for user management with CRUD endpoints, validation,
> tests, and OpenAPI docs

# Behind the scenes, Claude spawns parallel agents:
# Agent 1 (worktree: feat-users-a) → implements route handlers + validation
# Agent 2 (worktree: feat-users-b) → writes integration tests
# Agent 3 (worktree: feat-users-c) → generates OpenAPI spec from the schema

# Each works in isolation, main agent merges results
# You see progress updates as each agent completes

# You can also explicitly request parallel exploration
> research how both Prisma and Drizzle handle migrations,
> then compare them side by side
# Claude spawns two research agents simultaneously
```

## Danger Mode

Bypasses the permission prompts that normally gate tool execution — file writes, bash commands, etc. all run without asking for confirmation. Useful when you trust what Claude is doing and the constant approve/deny flow is slowing you down (e.g. during a well-understood refactor or test run). Obviously use with caution — you're removing the safety net that prevents unintended destructive actions. Best combined with git so you can always roll back.

```sh
# Launch Claude Code with no permission prompts
claude --dangerously-skip-permissions

# Or use the "yolo" mode for a single session
# Claude will read, write, execute bash, and commit without asking

# Safety tip: always ensure you're on a clean branch first
git checkout -b experiment/dangerous-refactor
claude --dangerously-skip-permissions
# If anything goes wrong:
git checkout main && git branch -D experiment/dangerous-refactor

# Scoped alternative: allow specific tools without prompts
claude --allowedTools Edit,Write,Bash
```
