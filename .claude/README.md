# Claude Code Workspace — Flutter Engineering Playbook

This `.claude/` directory carries my portable Flutter engineering standard. It is project-agnostic:
drop it into any Flutter repository and Claude will inspect that repo (package name, existing structure)
and apply these standards to new code. Start with the root [`CLAUDE.md`](../CLAUDE.md) — it is the primary
knowledge base.

> **Golden rule:** respect existing code. Never refactor/rename/move/reformat existing files unless a task
> explicitly targets them. Every data-driven feature follows Clean Architecture
> (Presentation → Domain → Data) — see `docs/ARCHITECTURE.md`.

## Layout

```
.claude/
├── settings.json         # Hook wiring (codegen reminder on Write/Edit)
├── README.md             # (this file)
├── agents/               # Specialized sub-agents
├── skills/               # Step-by-step generators following the playbook conventions
├── commands/             # Slash commands
├── hooks/                # Advisory, read-only hook scripts (+ README)
└── docs/                 # Deep-dive references
    ├── ARCHITECTURE.md   # Clean Architecture standard + worked example
    ├── WORKFLOWS.md      # Ordered playbooks (add feature/API/model/cubit/… + commit/PR)
    ├── CONVENTIONS.md    # Enforceable coding conventions
    └── CHECKLISTS.md     # Copy-paste checklists per task type
```

## Agents (`agents/`)
`flutter-architect` · `feature-builder` · `api-engineer` · `repository-engineer` · `cubit-engineer`
· `ui-engineer` · `theme-engineer` · `model-engineer` · `localization-engineer` ·
`build-runner-engineer` · `dependency-engineer` · `bugfix-engineer` · `code-reviewer`

## Skills (`skills/`)
`create-feature` · `create-screen` · `create-cubit` · `create-state` · `create-repository` ·
`create-datasource` · `create-retrofit-api` · `create-model` · `create-entity` · `create-usecase` ·
`create-mapper` · `create-bloc-listener` · `create-dialog` · `register-dependency` · `add-route` ·
`run-build-runner` · `review-feature`

## Commands (`commands/`)
`/build-runner` · `/new-feature` · `/review-feature` · `/analyze-project` · `/gen-clean`

## Quick starts
- **Add a feature:** `/new-feature <name> GET <endpoint/path> → <brief description>`
- **After editing a model/state/api:** `/build-runner`
- **Review your branch:** `/review-feature`
- **Check conventions locally:** `bash .claude/hooks/validate_conventions.sh`
