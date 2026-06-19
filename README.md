# Agent Scaffold

[中文文档](README.zh-CN.md)

> Training wheels for LLM agents — install when needed, remove when internalized.

## What is this?

Agent Scaffold is a set of **optional training aids** for LLM agents (Hermes, OpenClaw, etc.). Unlike knowledge bases that teach "what to do," scaffolds provide **mechanisms** that help agents build good habits:

- **Statistics** — Track which skills were used
- **Verification** — Check if outputs meet standards
- **Feedback** — Generate reports for human review

The goal is simple: **help agents internalize good practices, then get out of the way.**

## Philosophy

```
Novice → Install scaffolds → Build habits → Internalize → Remove scaffolds → Mature
```

Scaffolds are **not mandatory rules**. They are optional aids that:
- Help beginners establish good workflows
- Provide visibility into agent behavior
- Can be disabled once habits are formed
- Add overhead (token cost) when active

## Included Scaffolds

### 1. Task Execution Reporter

**Purpose**: Generate execution reports after tasks + semantic verification via sub-sessions

**What it does**:
- Tracks which skills were loaded
- Counts tool calls and execution time
- Runs automatic verification checks
- **Spawns a zero-context sub-session to detect intent drift and context pollution**
- Suggests improvements

**When to use**:
- ✅ Building skill-selection habits
- ✅ Monitoring execution quality
- ✅ Debugging workflow issues

**When to disable**:
- ✅ Skills already selected accurately
- ✅ Simple tasks don't need overhead
- ✅ User says "no report needed"

### 2. Pure Output

**Purpose**: Eliminate AI-speak, improve token efficiency

**What it does**:
- Bans filler phrases ("Great question!", "I'd be happy to...")
- Enforces direct, concise communication
- Promotes active voice and short sentences

**When to use**:
- ✅ Writing long documents
- ✅ User feedback is "too verbose"
- ✅ Catching yourself in templates

**When to disable**:
- ✅ Output style already internalized
- ✅ Casual conversation doesn't need it

### 3. Self-Verification

**Purpose**: Ensure outputs are actually correct

**What it does**:
- File operations → read back to verify
- Command execution → check exit codes
- Data processing → sample verification
- Config changes → validate immediately

**When to use**:
- ✅ After file operations
- ✅ After important commands
- ✅ After batch data processing

**When to disable**:
- ✅ Verification habits already formed
- ✅ Simple operations don't need it

## Installation

```bash
git clone https://github.com/JingWang-Star996/agent-scaffold.git
cd agent-scaffold
./install.sh
```

**Options**:

```bash
# Install to Hermes only
./install.sh --hermes

# Install to OpenClaw only
./install.sh --openclaw

# Install all scaffolds (default)
./install.sh

# Install specific scaffolds only
./install.sh --only task-execution-reporter,pure-output

# Install to both (auto-detect)
./install.sh
```

## Usage

After installation, scaffolds are available as skills:

**Hermes**:
```
/skill task-execution-reporter
```

**OpenClaw**:
```
Load skill: task-execution-reporter
```

Scaffolds activate automatically based on their trigger conditions. See each scaffold's documentation for details.

## Disabling Scaffolds

Scaffolds are optional. Disable them when no longer needed:

**Temporary** (current session):
- Don't load the scaffold skill

**Permanent**:
```bash
# Hermes
rm -rf ~/.hermes/skills/task-execution-reporter

# OpenClaw
rm -rf ~/.openclaw/skills/task-execution-reporter
```

Or use the uninstall script:
```bash
./uninstall.sh
```

## How It Works

### Task Execution Reporter Flow

```
Task completes
    ↓
Auto-collect data
  - Tool call count
  - Skills loaded
  - Execution time
    ↓
Run verification checks
  - Output style (pure-output)
  - Verification steps (self-verification)
  - Progress reporting
  - Skill completeness
    ↓
Generate report
  - Task overview
  - Skill statistics
  - Verification results
  - Improvement suggestions
    ↓
Human review
  - Confirm quality
  - Identify gaps
  - Provide feedback
    ↓
Continuous improvement
  - Update skill mappings
  - Refine workflows
```

### Example Report

```
📊 Task Execution Report
═══════════════════════════════════════

## Task Overview
- Type: Code refactoring
- Duration: 45s
- Tool calls: 8
- Token usage: ~12,000

## Skills Loaded
| Skill | Purpose | When |
|-------|---------|------|
| pure-output | Output style | Start |
| self-verification | Verification | After file ops |

## Auto-Verification
- [✅] Output style: No AI-speak
- [✅] Verification: Read back 3 files
- [✅] Progress: Reported 2x
- [✅] Delivery: Complete

## Needs Human Confirmation
- Missing architecture-decision-records?
- Code quality as expected?
- Need unit tests?

## Improvement Suggestions
- Load architecture-decision-records next time
- Consider adding test coverage check
```

## Semantic Verification

A key feature of the Task Execution Reporter is **semantic verification** — detecting when the agent has drifted from the user's original intent due to context pollution.

### The Problem

When a conversation is long, the agent gets anchored to previous operation patterns. For example:
- User says "check if tree-sitter is working"
- Agent was previously installing tree-sitter
- Agent interprets "check" as "install again" instead of "verify it's working"

This is **context pollution** — the agent can't self-diagnose because it's trapped in the same contaminated context.

### The Solution

Spawn a **zero-context sub-session** that only sees a structured **Verification Manifest** (~300-500 tokens), not the full conversation history:

```yaml
verification_manifest:
  original_intent: "Verify tree-sitter is working in the project"
  task_type: "verification"
  expected_state:
    - check: "tree-sitter config exists"
      evidence_cmd: "ls .tree-sitter/config.json"
    - check: "Code uses tree-sitter API"
      evidence_cmd: "grep -r 'tree_sitter' src/ | head -5"
  actual_evidence:
    - check: "tree-sitter config exists"
      output: ".tree-sitter/config.json"
      exit_code: 0
    - check: "Code uses tree-sitter API"
      output: "(empty)"
      exit_code: 1
  execution_trace:
    total_calls: 12
    categories: {install: 8, configure: 2, verify: 0, search: 2}
    # ↑ verify:0 is a red flag — intent is verification but zero verify ops
```

The sub-session checks three things:
1. **Intent-trace consistency**: task_type is "verification" but verify count is 0 → 🚩
2. **Expected-actual match**: which expected states lack supporting evidence?
3. **Operation pattern drift**: intent says "verify" but trace is all "install" → 🚩

### Configuration

```yaml
semantic_verification:
  enabled: true          # Master switch
  trigger_threshold: 5   # Min tool calls before triggering
  task_types:            # Which task types need verification
    - verification
    - analysis
    - diagnosis
  checkpoint_mode: false # Checkpoint mode vs post-completion only
```

## Comparison: ECC vs Scaffold

| Dimension | ECC | Agent Scaffold |
|-----------|-----|----------------|
| **Nature** | Knowledge (best practices) | Mechanism (statistics, verification) |
| **Answers** | "How to do it" | "Did you do it?" |
| **Origin** | Ported from Claude Code | Original for Hermes/OpenClaw |
| **Dependency** | Requires ECC repo | Independent |
| **Scope** | ECC skill users | All agent users |

**They complement each other**:
- ECC = what to do (knowledge)
- Scaffold = did you do it (mechanism)
- Both together = complete training system

## Project Status

**Current scaffolds**: 3
- task-execution-reporter
- pure-output
- self-verification

**Planned scaffolds**:
- skill-recommender — Suggest skills based on task type
- progress-tracker — Track long-running tasks
- error-pattern-detector — Identify recurring mistakes

## Contributing

Contributions welcome! Areas for improvement:
- Add more scaffolds
- Improve verification rules
- Add language-specific scaffolds
- Translate documentation

## License

MIT

## Credits

- Inspired by the need for **agent training aids** in the Hermes/OpenClaw community
- Built on the principle that **LLMs are probabilistic** and need scaffolding, not just rules
- Designed to be **optional and removable** — the goal is to outgrow them

---

**Training wheels for the AI age** 🚲
