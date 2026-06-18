# Agent Scaffold Philosophy

> Training wheels for the AI age

## The Problem

LLMs are **probabilistic**, not deterministic. Unlike traditional software where `if condition then action` is 100% reliable, LLMs operate on `if condition probably action`.

This means:
- System prompts say "MUST load skill" → LLM loads it ~70% of the time
- Rules say "always verify output" → LLM verifies ~80% of the time
- Guidelines say "report progress" → LLM reports ~60% of the time

**The gap between "should do" and "actually does" is where problems happen.**

## The Solution: Scaffolding, Not Rules

Traditional approach: **More rules**
```
SOUL.md: "You MUST always verify output"
SOUL.md: "You MUST always load skills"
SOUL.md: "You MUST always report progress"
```

Problem: LLMs don't follow rules deterministically. More rules ≠ more compliance.

Our approach: **Mechanisms that help build habits**
```
Scaffold: "After task completion, generate execution report"
  ↓
Report shows: "Skills loaded: 0/3 recommended"
  ↓
Human sees the gap → provides feedback
  ↓
LLM learns → next time loads skills more consistently
  ↓
Eventually: habits internalized → scaffold removed
```

## The Training Arc

```
Novice → Install scaffolds → Build habits → Internalize → Remove scaffolds → Mature
```

### Novice Stage

**Characteristics**:
- Doesn't know which skills to load
- Forgets to verify outputs
- Skips progress reporting
- Makes avoidable mistakes

**Scaffolds needed**:
- ✅ task-execution-reporter (shows what was missed)
- ✅ pure-output (enforces communication style)
- ✅ self-verification (forces verification steps)

**Goal**: Build awareness of good practices

### Growth Stage

**Characteristics**:
- Loads most relevant skills
- Verifies outputs consistently
- Reports progress naturally
- Makes fewer mistakes

**Scaffolds needed**:
- ⚠️ task-execution-reporter (occasional check-ins)
- ❌ pure-output (internalized)
- ❌ self-verification (internalized)

**Goal**: Reduce overhead, maintain quality

### Mature Stage

**Characteristics**:
- Skill selection is accurate
- Verification is automatic
- Communication is concise
- Rarely makes avoidable mistakes

**Scaffolds needed**:
- ❌ None (all internalized)

**Goal**: Maximum efficiency, minimal overhead

## Why Not Just Use Rules?

**Rules are necessary but insufficient.**

Rules define **what should happen**. Scaffolds provide **mechanisms to help it happen**.

```
Rule: "Load relevant skills before starting tasks"
  ↓
Problem: LLM forgets ~30% of the time
  ↓
Scaffold: "After task, report shows skills loaded: 0/3"
  ↓
Human: "You should have loaded X, Y, Z"
  ↓
LLM: "Got it, will load next time"
  ↓
After 10 reminders: LLM loads skills ~95% of the time
  ↓
Scaffold removed: Rule is now internalized
```

## The Feedback Loop

```
Execute task
    ↓
Scaffold generates report
    ↓
Human reviews report
    ↓
Human provides feedback
    ↓
LLM updates mental model
    ↓
Next task: better execution
    ↓
Eventually: scaffold no longer needed
```

This is **supervised learning in production** — not training the model weights, but training the **instance behavior** through feedback.

## Design Principles

### 1. Optional, Not Mandatory

Scaffolds are **training aids**, not rules. Users choose:
- Install all scaffolds
- Install specific scaffolds
- Install none

### 2. Removable, Not Permanent

The goal is to **outgrow** scaffolds. Once habits are internalized:
- Disable the scaffold
- Reduce token overhead
- Maintain quality

### 3. Transparent, Not Opaque

Scaffolds show **what happened**, not just **what should have happened**:
- "Skills loaded: pure-output, self-verification"
- "Verification steps: 3/5 completed"
- "Progress reports: 2 during 45s task"

### 4. Lightweight, Not Heavy

Scaffolds add **minimal overhead**:
- Simple checks, not complex analysis
- Quick reports, not exhaustive audits
- Optional details, not mandatory reading

## Comparison: Rules vs Scaffolds

| Dimension | Rules | Scaffolds |
|-----------|-------|-----------|
| **Nature** | Declarative ("must do X") | Mechanistic ("here's what happened") |
| **Enforcement** | Probabilistic (LLM compliance) | Observational (human review) |
| **Persistence** | Permanent (in SOUL.md) | Temporary (until internalized) |
| **Overhead** | Always present (in context) | Only when active |
| **Goal** | Define standards | Build habits |

## The Bigger Picture

Agent Scaffold is part of a broader shift in how we think about LLM agent development:

**Old model**: Write better prompts → hope LLM follows them

**New model**: Provide mechanisms → help LLM build habits → remove mechanisms

This is closer to how **humans learn**:
- Training wheels on a bike
- Guidelines for writing essays
- Checklists for surgery
- Mentorship for leadership

We don't expect humans to learn perfectly from rules alone. Why expect it from LLMs?

## Future Directions

### Planned Scaffolds

- **skill-recommender** — Suggest skills based on task type
- **progress-tracker** — Track long-running tasks
- **error-pattern-detector** — Identify recurring mistakes
- **habit-scorer** — Track improvement over time

### Integration with ECC

Agent Scaffold complements ECC:
- **ECC** = knowledge (what to do)
- **Scaffold** = mechanism (did you do it?)

Together: complete training system

### Community Contributions

We welcome:
- New scaffolds
- Improved verification rules
- Language-specific scaffolds
- Translations

## Conclusion

Agent Scaffold is an experiment in **LLM agent training**.

The hypothesis: **LLMs can build good habits through supervised feedback, just like humans.**

The mechanism: **Optional scaffolds that provide visibility and feedback, then get out of the way.**

The goal: **Mature agents that don't need scaffolds anymore.**

---

*Training wheels for the AI age* 🚲
