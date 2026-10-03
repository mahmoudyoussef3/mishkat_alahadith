# The Engineering Workspace — An Onboarding Handbook

A working handbook for the `.claude/` system in this repository: what each file does, why it exists,
how the pieces interact, and where the documented standard and the actual codebase currently disagree.

Written from a full read of all 45 files in `.claude/`, plus `pubspec.yaml`, `lib/core/`, and the
`login` / `home` features, on the `development` branch. Where this handbook says the playbook and the
repository disagree, that was verified against the source, not inferred.

**At a glance:** 45 files in `.claude/` · 13 agents · 17 skills · 5 commands · 3 hooks (**1 wired**) ·
package name `flutter_complete_project`

> **Reality check — read this first.** The playbook describes a **target state this repository has never
> been in**. Every existing feature (`login`, `home`, `sign_up`) is a clean **two-layer** design —
> `data/` + `logic/` + `ui/`, no `domain/`, concrete repos, DTOs reaching the Cubit. `CLAUDE.md`
> prescribes **three layers**. Both are legitimate. The divergence is real, currently undocumented, and
> threaded through this handbook wherever it matters.

---

## Table of contents

1. [Overall philosophy](#1-overall-philosophy)
2. [CLAUDE.md](#2-claudemd)
3. [Agents](#3-agents)
4. [Skills](#4-skills)
5. [Hooks](#5-hooks)
6. [Development workflow](#6-development-workflow)
7. [End-to-end: "Create Login Feature"](#7-end-to-end-create-login-feature)
8. [Engineering principles](#8-engineering-principles)
9. [Interview perspective](#9-interview-perspective)
10. [Architectural decisions](#10-architectural-decisions)
11. [Best practices](#11-best-practices)

---

## 1. Overall philosophy

### The purpose

This workspace exists to solve one problem: **a language model has no memory of your standards, and
infinite willingness to invent new ones.** Ask an unprimed model for a Flutter feature and it will
produce something reasonable — but it might reach for Riverpod, or Provider, or hand-rolled `setState`.
It might construct its own `Dio`. It might inline `Color(0xFF247CFF)` instead of using
`ColorsManager.mainBlue`. Every one of those choices is defensible in isolation, and every one of them is
wrong *here*, because consistency is worth more than local optimality.

The workspace converts your standards from tribal knowledge into **machine-readable, version-controlled
artifacts**. It answers, before any code is written: which libraries, which folder layout, which naming
scheme, which error type, which spacing helper.

### Why it beats working without it

Without it, every conversation starts from zero. You re-explain the architecture, you catch the same
deviations in review, and the corrections evaporate when the session ends. The cost isn't one bad file —
it's **drift**. Ten features built across ten conversations produce ten dialects of the same codebase,
and the cost of that drift compounds: every new engineer has to learn all ten.

With it, the standard is loaded before the first token of code. Corrections get written back into the
playbook rather than lost, so the system gets *sharper* over time instead of decaying.

### The problems it actually solves

| Failure mode | Mechanism that prevents it |
|---|---|
| Library drift (Riverpod appears in feature 7) | `CLAUDE.md` §2 fixes the stack; agents restate "do not introduce new libraries" |
| Architecture erosion (UI calls the repo directly) | `ARCHITECTURE.md` dependency rule; `code-reviewer`; `validate_conventions.sh` check 4 |
| Stale generated code | `codegen_reminder.sh` fires automatically on every Write/Edit |
| Design-token bypass (hardcoded colors) | `theme-engineer` scope; `validate_conventions.sh` check 3 |
| Unrequested refactors of working code | The **golden rule**, repeated in ~12 separate files |
| Blank-page cost on every new feature | `create-feature` skill: 14 ordered steps |
| Review inconsistency | `CHECKLISTS.md` — the same list every time |

### How it improves code quality

Four distinct ways, worth separating because they fail independently:

- **Prevention** — the playbook shapes code before it's written. Cheapest.
- **Constraint** — agents have narrowed tool access. The `flutter-architect` has only `Read, Grep, Glob`;
  it *cannot* edit a file even if it wanted to. This is real enforcement, not a polite request.
- **Detection** — hooks and the reviewer catch what slipped through.
- **Repeatability** — a skill produces the same shape on Tuesday as it did on Monday.

### How it scales across projects

The playbook is written to be **project-agnostic**. It never hardcodes the package name; it says
`<app_name>` and instructs the reader to get the real value from `pubspec.yaml` — which in this repo is
`flutter_complete_project`, notably *not* the folder name `flutter_advanced_course`. That single
indirection is what makes `.claude/` portable: copy the directory into any Flutter repo, and the first
instruction every agent follows is "inspect this repository."

The scaling model is: **the playbook is the constant, the repo is the variable.** The golden rule is what
makes that safe — dropping the workspace into an established codebase can't trigger a rewrite, because
the standard applies to *new* code and existing conventions win in existing files.

---

## 2. CLAUDE.md

The constitution. 15 sections, loaded into context automatically, before anything else.

### Why it exists

It's the **single source of truth for how you build Flutter software**. Everything else in `.claude/` is
downstream of it: agents cite it by section number, skills implement its templates, hooks enforce a
subset of its rules. If `CLAUDE.md` and an agent ever disagree, `CLAUDE.md` wins.

### When it's read

Automatically, at the start of every session, injected into the system context before the first user
message is processed. This is the critical property and the most common misunderstanding: **nobody has to
ask for it**. It is not retrieved on demand, not searched for, not conditionally loaded. It's simply
there. That's why it earns the right to be long — and why it must not be padded, since every token is
spent on every single request in the session, forever.

### How it influences generated code

Trace a single rule to see the mechanism. §11 says colors come only from `ColorsManager`. That one
sentence:

- shapes the model's default when writing any widget;
- is restated in `ui-engineer.md` and `theme-engineer.md` as a scope rule;
- is templated into `create-screen`;
- is a line item in `CHECKLISTS.md`;
- is grep-detectable by `validate_conventions.sh` check 3.

That's **defense in depth**. Five independent layers, so no single failure lets a hardcoded `Color(0x...)`
reach the branch.

### What belongs, and what doesn't

| Belongs | Never |
|---|---|
| Non-obvious, durable conventions | Anything derivable by reading the code |
| The fixed stack, and that it's fixed | Secrets, tokens, credentials |
| Naming tables, folder shape | Task-specific or ticket-specific context |
| Explicit prohibitions ("never hand-edit `.g.dart`") | Volatile facts (sprint goals, current bugs) |
| Exact commands with exact flags | Onboarding prose for humans (that's README's job) |
| Pointers to deeper docs | Long code that duplicates a skill file |

The economics: it's **always-on context**. A rule earns its place if violating it would cost real review
time. "Use Cubit, never Bloc" earns it — the model would otherwise reach for Bloc roughly half the time.
"Dart uses semicolons" doesn't.

### How it differs from README.md and from project docs

`README.md` is **for humans, describing what is**: how to clone, install, run. Descriptive and
onboarding-oriented. `CLAUDE.md` is **for an agent, prescribing what must be**: imperative, written as
rules, with explicit prohibitions. A README saying "don't hand-edit generated files" would be odd. In
`CLAUDE.md` it's essential, because the reader is a system that would otherwise cheerfully do it.

Against project docs the axis is **load-bearing vs. reference**. `CLAUDE.md` is always loaded and
therefore rationed. `.claude/docs/*.md` is loaded *on demand* — which is exactly why §4 ends with "See
`.claude/docs/ARCHITECTURE.md` for a full worked example." That line is a deliberate **context-budget
decision**: the 245-line worked example is one `Read` away when needed, and costs nothing when it isn't.
Learn to see that pattern — it's the core design move of the whole workspace.

### The 15 sections

| § | Section | Load-bearing rule |
|---|---|---|
| 1 | Architecture philosophy | Feature-first Clean Architecture; bootstrapping order |
| 2 | Tech stack | The stack is *closed*. No alternatives. |
| 3 | Folder structure | The canonical tree; simple features may skip layers |
| 4 | Layer rules | The dependency direction + data flow |
| 5 | State management | Cubit + freezed; cubit owns form state |
| 6 | Networking | One Dio; repos return `ApiResult`, never throw |
| 7 | Models & JSON | Nullable responses; `@JsonKey`; entity+mapper pairing |
| 8 | Routing | Never `Navigator.of(context)` in feature code |
| 9 | Code generation | Commit generated files; never hand-edit |
| 10 | Naming | The naming table — the highest-density section |
| 11 | Theming | Tokens only; ScreenUtil on every number |
| 12 | DI | lazySingleton for services, factory for cubits |
| 13 | Workflow | The 9-step feature loop |
| 14 | Do's and Don'ts | Compressed recap — the highest-salience section |
| 15 | The Claude workspace | Points at agents/skills/commands/docs |

§14 exists purely as a **salience device**. It's redundant by design: a scannable Do/Don't list near the
end, because models weight the beginning and end of long context most heavily. That's not sloppiness —
it's writing for the reader you actually have.

---

## 3. Agents

Thirteen specialists in `.claude/agents/`. Each is a markdown file with YAML frontmatter defining its
name, description, tool access, and model.

### What an agent actually is

An agent is a **subagent with a fresh context window, a narrow system prompt, and a restricted toolset**.
When one is invoked, it does not inherit the conversation. It starts cold, does its job, and returns a
summary. Three consequences worth internalizing:

- **Context isolation is the main benefit.** A 40-file exploration inside an agent doesn't pollute the
  main thread. Only the conclusion comes back.
- **Cold start is the main cost.** The agent re-derives context you already had. This is why you
  shouldn't spawn one for work you could just do.
- **Tool restriction is the main enforcement.** The `tools:` line is a hard capability boundary, not
  advice.

### The tool-access hierarchy — read this as a permission system

| Tier | Tools | Agents | Meaning |
|---|---|---|---|
| Advisory | `Read, Grep, Glob` | `flutter-architect` | Physically cannot write. Advice only. |
| Advisory + verify | `+ Bash` | `code-reviewer`, `build-runner-engineer` | Can run analyze/codegen; cannot edit source. |
| Additive | `+ Write, Edit` | `feature-builder`, `api-engineer`, `cubit-engineer`, `model-engineer`, `repository-engineer`, `localization-engineer` | Full authoring. |
| Surgical | `Read, Grep, Glob, Edit` *(no Write)* | `bugfix-engineer`, `dependency-engineer` | **No Write = cannot create files.** Structurally forced to make minimal edits. |
| Scoped-surgical | `Read, Grep, Glob, Edit` | `theme-engineer` | Append tokens to 3 known files. |
| No Bash | `Read, Grep, Glob, Write, Edit` | `ui-engineer` | Can't run codegen — because pure UI never needs it. |

Look closely at the **surgical** tier. Denying `Write` to the `bugfix-engineer` is the sharpest design
decision in the whole workspace. A bug fix that needs a *new file* is almost always a bug fix that has
quietly become a refactor. Removing the tool makes scope creep *impossible* rather than merely
discouraged. Prompt says "be surgical"; tool list *enforces* surgical. Prefer the second whenever you can
express a rule that way.

### The thirteen, individually

---

#### `flutter-architect` — `Read, Grep, Glob`

- **Why it exists.** Planning and doing are different skills, and mixing them causes the model to start
  typing before it has decided where code belongs. This agent separates the decision from the execution.
- **When invoked.** Before any non-trivial feature; for "where should this live?"; for refactoring advice;
  for evaluating structure.
- **Decides.** Folder tree, file list and responsibilities, DI registrations, route wiring, whether the
  feature is data-driven (three layers) or presentation-only (UI + optional Cubit).
- **Cannot.** Write anything. Propose new libraries. Propose parallel infrastructure. Suggest refactors of
  unrelated files.
- **Prevents.** The most expensive class of mistake — structural error discovered after 15 files exist.

#### `feature-builder` — `+ Write, Edit, Bash`

- **Why it exists.** A full feature is ~14 files across 3 layers in a strict order. Sequencing it by hand
  invites omissions (the forgotten DI line, the missing route).
- **When invoked.** "Add a complete new feature." The heavyweight path.
- **Responsibilities.** Executes Workflow A: skeleton → models → datasource → entities → repo interface →
  mapper → repo impl → use cases → state → cubit → screen → listener → DI → routes → codegen → analyze.
- **Cannot.** Touch *any* existing file except three: `dependency_injection.dart`, `routes.dart`,
  `app_router.dart` — and only additively. This is the sharpest constraint in the file and the one you
  should verify in review.
- **Prevents.** Half-wired features. Its report format — full file list + exact DI/route lines — makes
  omissions visible.

#### `api-engineer` — `+ Write, Edit, Bash`

- **Why it exists.** Networking has the highest ratio of invisible-mistake to visible-code. A second `Dio`
  instance compiles, runs, and silently drops your auth header.
- **When invoked.** New endpoint; new API service; Dio/interceptor/timeout config; error-pipeline work.
- **Decides.** Central (`core/networking/api_service.dart`) vs. feature-level service — the rule is
  *shared/auth is central, feature-specific is local*. Also verb, params, and the shape of
  request/response models.
- **Cannot.** Construct `Dio()`. Hardcode a base URL. Hand-edit `.g.dart`.
- **Collaborates.** Hands models to `model-engineer`, the repo method to `repository-engineer`, the DI
  line to `dependency-engineer`.

#### `repository-engineer` — `+ Write, Edit, Bash`

- **Why it exists.** The repository is the **architectural seam** — the one place where "the network can
  fail" gets converted into "the domain has a typed result." Get this wrong and exceptions leak into
  Cubits, and every Cubit grows a try/catch.
- **When invoked.** Any data access for a feature.
- **Responsibilities.** Domain interface + data implementation. Three steps only: **call → map → wrap**.
- **Cannot.** Let a repo throw. Put business logic or UI concerns in a repo. Return a *model* where an
  entity is contracted.
- **Prevents.** The single most consequential leak in the architecture: exceptions crossing into
  presentation.

#### `cubit-engineer` — `+ Write, Edit, Bash`

- **Why it exists.** State is where correctness bugs concentrate: a missing `buildWhen` case means the UI
  silently doesn't update, and nothing errors.
- **When invoked.** Cubits, freezed states, BlocBuilder/BlocListener wiring.
- **Decides.** **Simple/generic state vs. multi-concern typed state.** One Cubit driving several
  independent UI regions needs prefixed typed factories so `buildWhen` can target them; a single-purpose
  Cubit uses the generic `success<T>`. This is a real judgment call and worth understanding.
- **Cannot.** Use Bloc/events. Skip `buildWhen`/`listenWhen`. Put side effects in the builder. Depend on a
  repo directly *in a data-driven feature* (must go through a use case).
- **Prevents.** Full-screen rebuilds; dialogs firing on every rebuild; unreachable states.

#### `ui-engineer` — `+ Write, Edit` (no Bash)

- **Why it exists.** UI is where hardcoded values leak in, because inlining a color is always the path of
  least resistance.
- **When invoked.** Screens, widgets, dialogs, lists, shimmer loading.
- **Cannot.** Hardcode colors/styles/URLs/raw pixels. Add business logic. Call `Navigator.of(context)`.
  Touch data or networking. **Run Bash** — a deliberate omission: pure UI never needs codegen, so removing
  the tool removes the temptation to "just regenerate."
- **Note.** It explicitly delegates BlocListener work to `cubit-engineer` — a documented handoff rather
  than a blurred boundary.

#### `theme-engineer` — `Read, Grep, Glob, Edit`

- **Why it exists.** `colors.dart` and `styles.dart` are referenced by nearly every widget. They are the
  highest-blast-radius files in the codebase.
- **When invoked.** A genuinely new design token is needed.
- **Cannot.** **Reorder or rename existing tokens** — append/extend only. Restyle existing screens. Create
  files (no `Write`).
- **Why append-only matters.** Renaming `ColorsManager.mainBlue` is a one-line edit with a hundred-file
  blast radius. The constraint is proportional to the risk.

#### `model-engineer` — `+ Write, Edit, Bash`

- **Why it exists.** The model layer is where the server's reality meets your type system. Servers send
  nulls where docs promise strings.
- **Responsibilities.** Owns the **full triad**: model (DTO) + entity + mapper. Deliberate — the three
  must agree, so one owner prevents an entity that the mapper can't actually produce.
- **Decides.** Nullability, `@JsonKey` mappings, and the null-safe defaults in the mapper (`id ?? 0`,
  `name ?? ''`) — the exact point where defensive nullable DTOs become confident non-null entities.
- **Cannot.** Put business logic or Flutter imports in models. Hand-edit `.g.dart`.

#### `localization-engineer` — `+ Write, Edit, Bash`

- **Why it exists.** To encode a **negative**: `easy_localization` and `intl` are in `pubspec.yaml`, but
  the app is not localized. Without this agent, a model seeing those deps would reasonably assume `.tr()`
  everywhere.
- **When invoked.** **Only when localization is explicitly requested.** Its own prompt says "Do nothing
  here unless the task explicitly asks."
- **The lesson.** A dependency in `pubspec.yaml` is *not* evidence of a convention. This agent exists to
  break exactly that inference.

#### `build-runner-engineer` — `Read, Grep, Glob, Bash`

- **Why it exists.** Codegen failures are opaque and the recovery ladder is non-obvious and
  **order-dependent**.
- **The ladder.** `pub get` → `build` → `build_runner clean` → `flutter clean && pub get` → read the
  actual error. Escalating cost — you don't start with `flutter clean`.
- **Cannot.** Write or Edit source at all — **no `Write`, no `Edit`**. It can only run commands and read.
  It cannot "fix" your model to make generation pass.
- **Prevents.** The classic anti-pattern: mangling a source model to appease the generator instead of
  fixing the real cause (usually a missing `part` directive).

#### `dependency-engineer` — `Read, Grep, Glob, Edit, Bash`

- **Why it exists.** Two jobs, both high-consequence: DI wiring (a missing line = runtime crash, not
  compile error) and `pubspec.yaml` (where architectural erosion enters).
- **Decides.** `registerLazySingleton` vs. `registerFactory`. Rule: **stateless and shareable →
  lazySingleton; holds per-screen state → factory.** A Cubit as a singleton would carry stale state and
  disposed controllers into the next screen.
- **Cannot.** Add state-management, DI, or networking libraries. Add anything not explicitly requested.
  Create files.
- **The gate.** To add a dependency it must "explain why it's needed and that no lighter existing option
  fits" — friction applied deliberately at the exact point where stacks rot.

#### `bugfix-engineer` — `Read, Grep, Glob, Edit`

- **Why it exists.** Bug fixing is the highest-risk moment for scope creep. You're already in the file;
  the mess is right there; refactoring is tempting.
- **Method.** Locate root cause *before* editing → confirm with evidence → smallest fix → verify.
- **Cannot.** **Create files** (no `Write`). Refactor, rename, reformat, or clean up nearby code. Change
  public APIs unless the bug requires it.
- **Its symptom table is the real value.** UI not updating → missing `buildWhen` case. 401 after login →
  `setTokenIntoHeaderAfterLogin` not called. Null crash → missing `@JsonKey` or non-defensive nullable.
  These map symptom → likely cause, which is what expensive debugging experience actually looks like.

#### `code-reviewer` — `Read, Grep, Glob, Bash`

- **Why it exists.** The last detection layer, and the one that closes the loop back to the playbook.
- **Cannot.** **Edit anything.** Report only.
- **Why report-only is right.** A reviewer that fixes is a reviewer you stop reading. Separating detection
  from correction keeps you in the loop on every judgment call — and prevents an "improvement" nobody
  asked for.
- **Its subtlest rule.** "Don't flag intentional-looking pre-existing patterns in untouched files as
  defects introduced by this change." Without it, a reviewer in *this* repo would flag every existing
  feature for lacking a domain layer, and the signal would drown.
- **Output.** Prioritized, `file:line`-referenced, **Must fix** vs. **Nice to have**.

---

### How agents collaborate

They do **not** talk to each other. Every agent returns to the main thread, which sequences the next call.
Star topology, not mesh — and that's deliberate: it keeps one place accountable for the whole and prevents
unbounded agent-spawns-agent recursion. The typical chain:

```
plan     flutter-architect  ──▶ (returns a plan; writes nothing)
           │
build    feature-builder    ──▶ or the granular chain below
           model-engineer ▸ api-engineer ▸ repository-engineer
           ▸ cubit-engineer ▸ ui-engineer ▸ dependency-engineer
           │
gen      build-runner-engineer
           │
verify   code-reviewer      ──▶ findings only; you decide
```

Note the shape: **advisory at both ends, authoring in the middle.** The agents that can't write bracket
the ones that can. Planning is read-only so it can't cheat by coding; review is read-only so it can't
quietly bury what it found.

### How they prevent architectural mistakes

Three mechanisms, in ascending order of strength:

1. **Scope** — each agent's prompt names what it owns, so it doesn't wander.
2. **Explicit prohibition** — every file has a "Rules"/"Cannot" section. Negative instructions are far
   more effective than hoping positive ones cover every case.
3. **Tool restriction** — the only one that's actually enforced by the runtime rather than by the model's
   cooperation. When a rule matters, express it here.

---

## 4. Skills

Seventeen procedures in `.claude/skills/<name>/SKILL.md`. Frontmatter carries `name` and `description`;
the body is the procedure.

### What a skill is

A skill is **packaged procedural knowledge, loaded on demand**. Only the one-line `description` sits in
context permanently; the body — templates, steps, guardrails — loads only when invoked. This is
**progressive disclosure**, and it's the whole reason skills exist as a separate concept: 17 skills cost
~17 lines of standing context, but deliver hundreds of lines of precise procedure exactly when relevant.

This also explains why the `description` field is the highest-leverage text in the file. It is the *only*
thing that determines whether the skill is ever found. Every description here follows the same shape:
**what it does, then "Use when…"** — a trigger condition, not just a summary.

### Skills vs. agents — the distinction that matters

| | Agent | Skill |
|---|---|---|
| Is a | Worker — a *who* | Procedure — a *how* |
| Context | Fresh, isolated window | Loads into the *current* context |
| Tools | Restricted by frontmatter | Uses whatever the caller has |
| Cost | Cold start; re-derives context | Cheap; just instructions |
| Composition | Can invoke skills | Can reference other skills |
| Best for | Big, self-contained work with judgment | A known procedure with a known shape |

The relationship is **agents *use* skills**. `feature-builder` (agent) follows `create-feature` (skill).
Same knowledge, two delivery mechanisms — one gives you isolation and enforcement, the other gives you
cheapness and composability.

The practical rule: **if you know exactly what needs doing, use the skill. If it needs exploration and
judgment, use the agent.** Adding one endpoint to a known service? `create-retrofit-api` — no isolation
needed, and an agent would waste a cold start re-reading files you already have open.

### How reusable skills create consistency

Consistency is **determinism about shape**. Free-forming a Cubit ten times gives ten slightly different
Cubits — all fine, collectively a mess. The skill carries a literal template, so the tenth matches the
first. The value isn't that the template is optimal; it's that it's *the same*. A codebase where every
Cubit looks alike is one where a reviewer can scan a new Cubit in ten seconds, because they're only
reading the diff against a shape they already know.

### How to design a new skill

1. **Description first.** "What it does. Use when `<trigger>`." If the trigger is vague, the skill is dead
   — it will never be selected.
2. **One job.** Note this workspace splits `create-cubit` from `create-state` even though the former makes
   both — because sometimes you only need the state. Granularity is a feature.
3. **Real templates, placeholders marked.** `<app_name>`, `<Feature>` — with an explicit note on where the
   real value comes from.
4. **Numbered steps in dependency order.** Not a checklist — a sequence.
5. **End with guardrails.** Every skill here closes with what not to do.
6. **Cross-reference, don't duplicate.** `create-datasource` says "Same as the `create-retrofit-api`
   skill" rather than restating it. One definition, one place to fix it.

### The seventeen, individually

#### Orchestrator

**`create-feature`** *(156 lines — the flagship)*
The whole feature: 14 ordered steps, skeleton through `flutter analyze`. Effectively a superset of 8 other
skills. Notably it opens with **"Inputs to confirm"** — feature name, endpoint + method + shape, whether it
needs a form. It *asks before building*, because guessing a response shape produces a feature that compiles
and fails at runtime. Interacts with everything; it's the integration test of the whole playbook.

#### Data layer

**`create-model`** *(74 lines)*
`@JsonSerializable` DTOs. Separate templates for request bodies (`toJson` only) and responses (`fromJson`
only) — the asymmetry is the point: you never deserialize a request body, so generating both directions is
noise. Ends with build_runner; non-optional, since the class doesn't compile without it.

**`create-retrofit-api`** *(63 lines)*
The `@RestApi` service + its `*ApiConstants`. Two files, always together — an endpoint path is never a
string literal at the call site.

**`create-datasource`** *(47 lines)*
The datasource abstraction: remote (Retrofit) and optionally local (over `SharedPrefHelper`). Explicitly
defers to `create-retrofit-api` for the remote half. It exists for the *local* case and for the moment a
feature needs both. YAGNI applies: "only added when a feature caches/persists data."

**`create-mapper`** *(45 lines)*
`extension XMapper on XModel { XEntity toEntity() }`. The boundary-crossing translator. An extension keeps
the conversion out of both the model and the entity, so neither knows about the other — the entity stays
ignorant of serialization; the model stays ignorant of domain.

**`create-repository`** *(75 lines)*
Interface (domain) + impl (data) + `ApiResult` + try/catch + mapping. The seam.

#### Domain layer

**`create-entity`** *(41 lines)*
Plain Dart. No annotations, no imports beyond Dart itself. Non-nullable where the app guarantees a value —
the inverse of the DTO's defensive nullability.

**`create-usecase`** *(39 lines — the shortest)*
One class, one action, `call()` delegating to a repo interface. The shortest file is also the most
contested idea in the playbook: most use cases here are one-line delegations, and critics call that
ceremony. See §10 for the honest trade-off.

#### Presentation layer

**`create-state`** *(54 lines)*
The freezed union alone. Two documented styles: simple/generic and multi-concern typed.

**`create-cubit`** *(70 lines)*
Cubit + state together. Asks up front what it injects (use case vs. repo) and whether it manages a form.

**`create-screen`** *(57 lines)*
Screen + `widgets/` folder. Decomposition is built into the template, not left to discipline.

**`create-bloc-listener`** *(78 lines)*
The side-effect widget: `listenWhen` + `whenOrNull`, child `const SizedBox.shrink()`. It gets its own file
*and* its own skill because separating side effects from rendering is the single highest-value convention
in the state layer. Dialogs in a builder fire on every rebuild. Making the listener a *physically separate
widget file* makes the mistake structurally hard.

**`create-dialog`** *(66 lines)*
`showDialog` alerts and `showModalBottomSheet` sheets, themed and dismissed via the context extension.

#### Wiring

**`register-dependency`** *(41 lines)*
Correct `setupGetIt` registration and, critically, the correct *lifetime*.

**`add-route`** *(53 lines)*
`Routes` constant + `AppRouter` case + `BlocProvider` if needed. Explicitly scoped: "Touch only
`routes.dart` and `app_router.dart`."

#### Operations

**`run-build-runner`** *(44 lines)*
Run codegen; recover from failure. The skill form of the `build-runner-engineer` — use the skill when you
just need the command, the agent when you need diagnosis.

**`review-feature`** *(48 lines)*
Scope via `git status` / `git diff --stat`, check against `CHECKLISTS.md`, report. **Do not edit code.**

### Commands — the fourth mechanism

`.claude/commands/*.md` are typed shortcuts (`/new-feature`). Frontmatter carries `description` and
`argument-hint`; `$ARGUMENTS` interpolates what you typed. A command is **an invocation, not a
capability** — it's the front door to a skill. The layering:

| Layer | Who triggers it | Example |
|---|---|---|
| Command | **You**, by typing | `/new-feature profile GET /profile` |
| Skill | **The model**, by matching the description | `create-feature` |
| Agent | **The model**, delegating | `feature-builder` |
| Hook | **The runtime**, on an event | `codegen_reminder.sh` |

Four triggers: human, model-inferred, model-delegated, automatic. Understanding *who pulls each lever* is
most of understanding the workspace.

The five commands: `/new-feature` (→ `create-feature`), `/review-feature` (→ `review-feature`),
`/build-runner`, `/gen-clean` (the nuclear option: clean → flutter clean → pub get → build → analyze),
`/analyze-project` (report-only, explicitly forbidden from auto-fixing).

---

## 5. Hooks

Three bash scripts. Exactly one is wired. This section is where expectation and reality diverge most
sharply, so read it carefully.

### What hooks are

Hooks are **shell commands the runtime executes on tool events** — the only part of the workspace that
doesn't depend on the model choosing to cooperate. `CLAUDE.md` is persuasion. Tool restrictions are
capability limits. Hooks are **automation**: they fire whether or not the model was paying attention.

They receive the tool payload as JSON on stdin and can return JSON on stdout to inject context back into
the conversation.

> **Reality check — what's actually wired.**
> `.claude/settings.json` contains **one** hook registration: `codegen_reminder.sh` on `PostToolUse`
> matching `Write|Edit`. That's the entire file.
>
> The other two scripts exist but are **not connected to anything**. `pre_commit_checks.sh` will never
> fire until you paste the config from `hooks/README.md` into `settings.json`. `validate_conventions.sh`
> is manual-only by design — you must run it yourself.
>
> So in the pipeline you might imagine, **"Runs Hooks" means one advisory reminder about codegen.**
> Nothing else fires automatically. Knowing this is the difference between trusting the system and
> understanding it.

### The design principles, and why they're right

The hooks README states three: **never modify code**, **never hard-block** (everything exits 0), **stay
portable** (bash + optional `python3`, no `jq`).

The "never block" choice is the interesting one, and it's contestable. The argument for advisory: a
blocking hook that misfires halts all work, and people respond by disabling hooks entirely — so a hook
that blocks wrongly once is worse than a hook that reminds gently a hundred times. The argument against:
an advisory hook is *ignorable*, and `pre_commit_checks.sh` will happily let you commit a failing analyze
with a warning nobody reads. **The workspace bets on trust; CI is where you'd put the teeth.** That's a
coherent position, but know that you're relying on discipline, not enforcement.

The portability constraint is quietly excellent: both scripts parse JSON via `python3` with a `sed`
fallback, so they run on a fresh machine with no `brew install`.

### The three, one by one

---

#### `codegen_reminder.sh` — **WIRED** · `PostToolUse` · `Write|Edit`

- **Problem it solves.** The most common failure in this stack: edit a `@freezed` or `@JsonSerializable`
  class, forget build_runner, get a baffling error about a missing `_$Something`. Or worse — *don't* get
  an error, and commit source that disagrees with its generated file.
- **Exactly what it does.** Reads the payload → extracts `tool_input.file_path` → exits if not `.dart` →
  exits if it *is* a generated file → exits if the file doesn't exist → greps for
  `part '*.(g|freezed).dart';` → if found, emits `additionalContext` with the command.
- **Why PostToolUse, not Pre.** It must inspect the file *as written*. Before the write, the `part`
  directive may not exist yet. The reminder is only meaningful after the fact.
- **The four early exits are the design.** Skipping `*.g.dart` / `*.freezed.dart` matters: without it,
  running build_runner would trigger reminders about the files build_runner just produced. An infinite nag
  loop.
- **Fires on.** Every `@freezed` state, every `@JsonSerializable` model, every `@RestApi` service, and
  `core/networking/api_result.dart`.

#### `pre_commit_checks.sh` — **NOT WIRED** · opt-in

- **Intended trigger.** `PreToolUse` on `Bash`; self-filters to commands containing `git commit`.
- **What it does.** Runs `flutter analyze`, writes to `/tmp/flutter_analyze.txt`, injects either "passed"
  or a WARNING with the last 20 lines.
- **The honest assessment.** It **always exits 0**. It cannot stop a bad commit. Its own message says
  "commit not blocked." As written it's a notification, not a gate.
- **Note the cost.** `flutter analyze` takes seconds to tens of seconds, and this runs on *every* commit.
  That latency is probably why it ships unwired — a real trade-off, not an oversight.
- **To enable.** Copy the `PreToolUse` block from `hooks/README.md` into `settings.json`. The matcher is
  `Bash` broadly; the script filters.

#### `validate_conventions.sh` — **MANUAL ONLY** · by design

Run it: `bash .claude/hooks/validate_conventions.sh`

Five grep checks:

1. `Navigator.of(context)` outside `extensions.dart`
2. `Dio()` outside `dio_factory.dart`
3. `Color(0x` outside `colors.dart`
4. `/presentation/` files importing `/data/`
5. `features/*/domain` importing Flutter/Dio/Retrofit/json

**Why manual.** Whole-`lib/` greps on every edit would be noisy and slow. And crucially: in a repo with
pre-existing violations, an automatic version would scream constantly about files you're forbidden to
touch. Its own output says so — "some hits may be in pre-existing files you shouldn't touch — do NOT
refactor them."

> **Reality check — two of the five checks are dead code here.**
> **Check 4** greps for files under a `/presentation/` path. **Check 5** greps `lib/features/*/domain`.
> Neither path exists in this repository — every feature uses `logic/` at the feature root and none has a
> `domain/` folder.
>
> So the two checks that guard the *most important* rules — the dependency direction and domain purity —
> **currently cannot fire.** They aren't broken; they're written for the target state. They will start
> working the moment the first playbook-shaped feature lands. Until then, checks 1–3 are your only
> automated convention signal, and the layer boundary is enforced by review alone.

---

## 6. Development workflow

The lifecycle of a feature, step by step — with an honest note about which steps are automatic and which
are conventions the model follows because it was asked to.

```
[auto]   CLAUDE.md loaded into context          ◀── runtime, before anything
   │
[you]    "Add a profile feature, GET /profile"
   │
[model]  Classify: data-driven? form? new endpoint?
   │
[model]  Inspect repo: pubspec name, core/, a sibling feature
   │
[model]  Select mechanism: command? skill? agent? inline?
   │
[model]  Plan (flutter-architect, read-only)
   │
[you]    ◀── APPROVAL GATE. Cheapest place to catch a mistake.
   │
[model]  Implement: data ▸ domain ▸ presentation ▸ DI ▸ routes
   │        └─ [auto] codegen_reminder fires on each annotated write
   │
[model]  build_runner ▸ flutter analyze
   │
[you]    /review-feature  ·  bash validate_conventions.sh
   │
[you]    Run the app. ◀── nothing above proves it works.
   │
[you]    Commit source + generated together
```

### Step by step

**1 · CLAUDE.md loads — automatic, before your message.**
Not a step the model takes; a precondition of the session. By the time your request is read, the standard
is already in context.

**2 · Classify the request.**
The decisive question is **data-driven or presentation-only?** §3 permits static screens to skip Domain and
Data entirely. Getting this wrong in either direction is expensive: three layers around a static onboarding
page is pure ceremony; a networked feature without them is the erosion the playbook exists to prevent.

**3 · Inspect the repository — the step that makes portability real.**
Every agent and skill opens with a version of this. Three things are read: the package name from
`pubspec.yaml`, the existing `core/` primitives, and a sibling feature for style. In *this* repo the
package is `flutter_complete_project` while the directory is `flutter_advanced_course` — guess the import
prefix from the folder name and nothing compiles.

**4 · Select the mechanism.**

| Situation | Reach for | Because |
|---|---|---|
| Whole new feature | `/new-feature` → `create-feature` | 14 ordered steps you'd otherwise sequence by hand |
| One endpoint on a known service | `create-retrofit-api` skill | Known shape; an agent's cold start is waste |
| "Where should this live?" | `flutter-architect` agent | Judgment; and read-only means it can't jump to code |
| Ambiguous bug, unclear cause | `bugfix-engineer` agent | Exploration would flood the main context |
| Add a color | Just do it | One line. Any mechanism is overhead. |

**5 · Plan.**
The architect returns a folder tree, file list with responsibilities, DI registrations, route wiring, and
the codegen step — and cannot write a line. Being unable to code is what makes it a good planner.

**6 · The approval gate.**
The most valuable step, and the one people skip. Cost of fixing a structural error at the plan stage: one
sentence. After 14 files exist and are wired into DI and routing: a small demolition. **Read the plan.**

**7 · Implement, in dependency order.**
Models → datasource → entity → repo interface → mapper → repo impl → use case → state → cubit → UI. Not
arbitrary: each step's output is the next step's input. Building the Cubit first means inventing a use case
signature you'll then have to conform to — and it'll be wrong, because you hadn't seen the response shape
yet.

**8 · Codegen and analyze.**
`dart run build_runner build --delete-conflicting-outputs`, then `flutter analyze`. The bar is **zero
*new* issues** — "new" because you inherit whatever exists and the golden rule says don't go fix it.

**9 · Review.**
`/review-feature` for the conventions, `validate_conventions.sh` for the greppable subset. Both report
only; you decide.

**10 · Run the app — the step the workspace can't do for you.**
Worth stating plainly: `flutter analyze` passing means it *compiles*. Nothing in the pipeline above proves
the feature *works*. A wrong `@JsonKey`, a missing DI registration, a `buildWhen` that omits your state —
all pass analyze and all fail at runtime. The workspace is excellent at shape and silent about behavior.

**11 · Commit.**
Source and generated files together, always. A commit with a changed model and a stale `.g.dart` is a
broken commit for everyone who checks it out.

---

## 7. End-to-end: "Create Login Feature"

The most instructive example available, because login already exists in this repo, built the old way. So we
get both: what the playbook would generate, and what's actually on disk.

> **Reality check — this is the divergence, concretely.**
> If you asked for login today, the correct response would be **"login already exists — did you mean to
> change it?"** and then a stop. The golden rule forbids rebuilding `lib/features/login/` into playbook
> shape unless you explicitly ask.

| Concern | Playbook target | Actual `lib/features/login/` |
|---|---|---|
| Presentation | `presentation/logic/` + `presentation/ui/` | `logic/cubit/` + `ui/` — no `presentation/` wrapper |
| Domain | `entities/ repos/ usecases/` | **Does not exist** |
| Repo | `LoginRepo` (abstract) + `LoginRepoImpl` | `LoginRepo` — one concrete class, no interface |
| Cubit depends on | `LoginUseCase` | `LoginRepo` directly |
| Cubit returns | `ApiResult<Entity>` | `ApiResult<LoginResponse>` — the **DTO reaches the Cubit** |
| Mapper | `data/mappers/` | None — nothing to map to |
| Datasource dir | `data/datasources/` | `home/data/apis/` (home); login uses central `ApiService` |

Both are internally consistent and both work. The existing code is a clean **two-layer** architecture —
data + presentation, repo returns `ApiResult`, error handling correct. The playbook prescribes
**three-layer**. Neither is broken; they're different points on a real trade-off, and §10 covers why you'd
choose each.

Note also that `ApiResult.failure` in this repo carries an `ErrorHandler`, which is why Cubits read
`error.apiErrorModel.message` — the `ErrorHandler` holds the model. That indirection surprises people on
first read.

### The pipeline, as it would actually execute

**Turn 0 — before you type.**
`CLAUDE.md` is already loaded. Cubit-not-Bloc, get_it, Retrofit, `ApiResult`, the naming table, the golden
rule: all in context.

**Turn 1 — classify.**
Login is data-driven (POST) and has a form. That answers: three layers, and the Cubit owns
`emailController`, `passwordController`, `formKey`.

**Turn 2 — inspect.**
Package is `flutter_complete_project`. `core/networking/` already has `ApiResult`, `ErrorHandler`,
`DioFactory`, and a central `ApiService`. **Auth is shared, so login belongs in the central service — not
a feature-level one.** That's `api-engineer`'s documented rule, and it's why login has no `data/apis/`
folder while home does.

**Turn 3 — mechanism.**
`/new-feature` → `create-feature` skill, executed by `feature-builder`. The skill first *confirms inputs*:
endpoint, request/response shape, form? Guessing here produces a feature that compiles and 400s.

**Turn 4 — plan (architect, read-only).**

```
features/login/
├── data/
│   ├── models/   login_request_body.dart   toJson only
│   │             login_response.dart       fromJson only, nullable
│   ├── mappers/  login_mapper.dart         LoginResponse ▸ AuthSession
│   └── repos/    login_repo_impl.dart      implements LoginRepo
├── domain/
│   ├── entities/ auth_session.dart         plain Dart
│   ├── repos/    login_repo.dart           abstract
│   └── usecases/ login_use_case.dart
└── presentation/
    ├── logic/    login_cubit.dart · login_state.dart
    └── ui/       login_screen.dart
                   widgets/ email_and_password.dart
                            login_bloc_listener.dart
```

No `datasources/` — login reuses the central `ApiService`. A generic scaffold would have created one
anyway; the architect knows not to.

**Turn 5 — implement, in order.**

1. **Models.** `LoginRequestBody` (`toJson`). `LoginResponse` (`fromJson`, nullable fields).
   *→ `codegen_reminder.sh` fires: both declare `part '*.g.dart'`.*
2. **Endpoint.** `ApiConstants.login` — central, since auth is shared.
3. **Service.** `@POST(ApiConstants.login) Future<LoginResponse> login(@Body() LoginRequestBody body);` on
   the existing `ApiService`. *→ reminder fires again.*
4. **Entity.** `AuthSession { final String token; final String name; }` — non-nullable. The domain asserts
   what the app guarantees.
5. **Repo interface.** `Future<ApiResult<AuthSession>> login(LoginRequestBody body);`
6. **Mapper.** `token: userData?.token ?? ''` — the exact line where nullable DTO becomes non-null entity.
7. **Repo impl.** call → map → wrap. try/catch → `ErrorHandler.handle(e)`.
8. **Use case.** `call(body) => _repo.login(body)`.
9. **State.** `@freezed`: initial/loading/success/error. *→ reminder fires (`part '*.freezed.dart'`).*
10. **Cubit.** Owns the controllers and formKey; injects the use case; emits loading → `result.when(...)`;
    saves the token and calls `DioFactory.setTokenIntoHeaderAfterLogin` on success.
11. **UI.** Screen + `email_and_password.dart` + `login_bloc_listener.dart` (loading dialog / navigate on
    success / error dialog).
12. **DI.** Four lines: service (lazySingleton), repo impl bound to the interface (lazySingleton), use case
    (lazySingleton), **cubit (factory)**.
13. **Route.** `Routes.loginScreen` + an `AppRouter` case with `BlocProvider`.

**Turn 6 — codegen & analyze.**
build_runner produces `login_request_body.g.dart`, `login_response.g.dart`, `api_service.g.dart`,
`login_state.freezed.dart`. Then analyze.

**Turn 7 — review.**
`code-reviewer` checks: presentation imports no `data/`; domain is pure; repo returns `ApiResult`;
`buildWhen`/`listenWhen` present; tokens not hardcoded; navigation via extension; DI complete; codegen
fresh. Reports; edits nothing.

**Turn 8 — the part the pipeline can't do.**
Run it. Log in with a real credential. Everything above is shape; only this is behavior.

### Where the login Cubit does something subtle

The existing `LoginCubit` owns its `TextEditingController`s. That looks like it breaks "presentation logic
stays in the widget," but it's deliberate: form *state* is state, and putting it in the Cubit means the
Cubit can read `emailController.text` without the widget passing it down. The trade-off is that the Cubit
now imports `flutter/material.dart` for `TextEditingController` — so the *Cubit* is not pure Dart. That's
fine: **the purity rule applies to `domain/`, not to presentation.** Candidates routinely get this wrong.

---

## 8. Engineering principles

How each principle is actually enforced here — mechanism, not aspiration.

### Clean Architecture

Enforced by the dependency rule: Presentation → Domain ← Data. Domain is the center and depends on nothing
(except `ApiResult` from `core/` — a pragmatic compromise; a purist would define the result type in domain
and have core depend on it). The payoff is that domain has no reason to change when Retrofit or Dio does.

### SOLID

| | Where it lives |
|---|---|
| **S**ingle responsibility | One use case = one action. One widget per file. Listener separate from builder. |
| **O**pen/closed | New feature = new files + additive DI/route lines. Existing code isn't reopened. |
| **L**iskov | `LoginRepoImpl` must honor `LoginRepo`'s contract — including "never throws." |
| **I**nterface segregation | Per-feature repo interfaces, not one fat `AppRepository`. |
| **D**ependency inversion | The headline. Cubit → use case → *interface*. DI binds the impl: `registerLazySingleton<LoginRepo>(() => LoginRepoImpl(getIt()))` — the type parameter is the abstraction, the lambda is the concretion. |

That one DI line *is* dependency inversion made mechanical. If you can explain it, you can explain D.

### Separation of concerns

Vertical (feature-first: login can't reach into home) and horizontal (layers within a feature). The nice
property: you can delete a feature folder and the app still compiles, minus its routes and DI lines.

### Dependency injection

`get_it` as a service locator. Constructors take abstractions; `setupGetIt()` is the sole composition root.
Lifetime is the judgment call — **lazySingleton for stateless shared things, factory for anything holding
per-screen state.** A Cubit registered as a singleton carries stale state and disposed controllers into the
next screen; a repo registered as a factory just wastes allocations.

### Repository pattern

The seam. Three jobs: hide the source, convert exceptions to `ApiResult`, map DTO → entity. "Repos never
throw to callers" is the load-bearing sentence — it's what lets every Cubit be a clean
`result.when(success:, failure:)` with no try/catch anywhere in presentation.

### Feature-first architecture

Organize by *feature*, then by layer — not the reverse. Layer-first puts every model in one folder and
every screen in another, so a feature is smeared across the tree and every change touches four distant
directories. Feature-first keeps a change local: one folder, one PR, one reviewer.

### DRY — and its limit

`core/` is the DRY mechanism: `ApiResult`, `ErrorHandler`, `DioFactory`, `ColorsManager`, `TextStyles`,
spacing, extensions, `AppTextButton`. "Never reinvent them" appears in nearly every agent.

But note where the playbook *deliberately isn't* DRY: model, entity, and mapper hold overlapping fields.
That's not a violation — it's **the correct application of DRY**, which is about duplicating *knowledge*,
not *structure*. The DTO knows the server's wire format; the entity knows the app's domain. Those are two
facts that happen to look similar today and will diverge the moment the server renames a field. Collapsing
them couples your domain to someone else's schema.

### KISS

Cubit not Bloc; no events, no reducers. One Dio. A switch statement for routing, not a router DSL. Every
choice is the boring one.

### YAGNI

Visible in the exemptions: presentation-only features skip Domain and Data. Local datasources are "only
added when a feature caches data." Localization is opt-in despite being in `pubspec.yaml`.

Be honest, though: **a use case that only forwards to a repo is exactly what YAGNI argues against.** The
playbook chooses consistency over minimalism here. That's defensible — a uniform shape is worth something —
but you should be able to name it as a trade-off rather than pretend it isn't one.

### Maintainability

Comes from predictability. You can find any file without searching, because the naming table determines the
name and the folder structure determines the location.

### Scalability

Feature-first scales to teams: two engineers on two features touch disjoint folders and collide only in
`dependency_injection.dart` and `app_router.dart` — where changes are additive lines and git merges them
cleanly. That's not an accident; it's why those two files are the *only* existing files `feature-builder`
may touch.

### Testability

Structurally excellent. The Cubit depends on an *interface*, so a fake repo tests it with no HTTP. Domain is
pure Dart — `dart test`, no Flutter binding. Mappers are pure functions. `ApiResult` makes both paths
trivially constructible.

> **Reality check — testability vs. tests.**
> There is **no `test/` directory** in this repo, no testing dependency in `pubspec.yaml`, and **no agent or
> skill for writing tests**. The architecture is designed for testability that nothing currently exercises.
>
> This is the workspace's largest genuine gap. If you're asked "what would you add first?" — this is the
> answer. A `test-engineer` agent and a `create-cubit-test` skill would slot in naturally, and the
> architecture is already shaped to make them easy.

---

## 9. Interview perspective

What I'd ask, what a strong answer sounds like, where candidates fall down, and where I'd push.

---

### Q: Walk me through what happens when a user taps "Login."

**Strong answer.** The widget calls `context.read<LoginCubit>().emitLoginStates()`. The Cubit emits
`loading`, reads its own controllers, and calls the use case. The use case delegates to the repo
*interface*; get_it has bound that to `LoginRepoImpl`, which calls the Retrofit service on the shared Dio.
On success the response DTO is mapped to an entity and wrapped in `ApiResult.success`; on any throw,
`ErrorHandler.handle` produces an `ApiErrorModel` inside `ApiResult.failure`. The Cubit branches with
`result.when` and emits `success` or `error`. The BlocListener — not the builder — dismisses the loading
dialog and navigates.

**Why it's correct.** It names every layer in order, gets the direction of dependency right, and —
critically — knows the exception never escapes the repo.

**Common failure.** Saying "the Cubit calls the API." That's a two-layer mental model. I'd immediately ask:
*where does a `DioException` get caught, and what does the Cubit actually receive?* If they can't answer,
they've read about Clean Architecture but haven't built in it.

---

### Q: Why `ApiResult` instead of just throwing?

**Strong answer.** It makes failure part of the *type*. A `Future<User>` that throws lies about its
contract — the signature says you get a user, the reality is you might get an exception, and nothing forces
you to handle it. `Future<ApiResult<User>>` tells the truth, and freezed's `when` is exhaustive, so the
compiler makes you handle both branches. It also keeps try/catch in exactly one place per repo method
rather than smeared across every caller.

**Follow-up I'd ask.** What does `ApiResult.failure` actually carry in this codebase? *The precise answer:
an `ErrorHandler`, not an `ApiErrorModel` — which is why Cubits read `error.apiErrorModel.message`.*
Someone who's actually read the code knows this; someone reciting the pattern says "an error model."

---

### Q: Cubits are registered with `registerFactory` but repos with `registerLazySingleton`. Why?

**Strong answer.** Lifetime follows state. A repo is stateless — one instance is safe and avoids
re-allocating. A Cubit holds per-screen state and owns `TextEditingController`s that get disposed when the
screen closes. As a singleton, reopening login would hand you the previous screen's state and *disposed
controllers* — you'd get "A TextEditingController was used after being disposed."

**Common failure.** "Factories are fresher." True but not a reason. I want the specific failure mode. Naming
the disposed-controller crash proves they've hit it.

---

### Q: Why does the mapper exist? The model already has the fields.

**Strong answer.** To stop the server's schema from being the app's domain. The DTO is nullable everywhere
because servers lie; the entity is non-nullable because the app has decided its defaults. The mapper is
where that decision gets made explicitly — `id ?? 0`, `name ?? ''` — instead of leaking `?.` and `??` into
every widget. And when the server renames a field, one `@JsonKey` and one mapper line change; the domain and
the entire UI don't move.

**Follow-up.** When would you skip it? *Good answer: a presentation-only feature, or a genuine throwaway.
Better answer: acknowledging this repo skips it everywhere today and that's a real position, not a bug.*

---

### Q: Why must side effects live in a BlocListener and not a BlocBuilder?

**Strong answer.** `build` can run many times for one state and must be pure. Calling `showDialog` from a
builder means a dialog per rebuild — you get stacked dialogs, or a navigation that fires twice. Listener
fires once per state *change*. That's why it's a separate file rendering `SizedBox.shrink()`: the separation
is structural, not a matter of remembering.

---

### Q (scenario): After login, every subsequent request returns 401. Where do you look?

**Strong answer.** The token isn't reaching the header. Check that the Cubit calls
`DioFactory.setTokenIntoHeaderAfterLogin(token)` on success, that the token was actually saved to secure
storage, and — the subtle one — that nothing constructed a *second* `Dio`. If a service got its own
instance, the header was set on an object nobody is using. Which is precisely why
`validate_conventions.sh` check 2 greps for `Dio()`.

**What I'm testing.** Whether they connect a runtime symptom to an architectural rule. The single-Dio rule
looks like fussiness until it costs you an afternoon.

---

### Q (scenario): You add a state to the union and the UI doesn't update. No errors. Why?

**Strong answer.** `buildWhen` doesn't include it. It's the classic silent failure of this pattern: the
optimization that prevents unnecessary rebuilds becomes the thing that prevents the necessary one. Same
class of bug with `listenWhen` and a dialog that never appears.

**Follow-up.** How would you prevent it structurally? *Honest answer: you mostly can't — it's why
`maybeWhen(orElse:)` is the convention rather than `when`, and it's an argument for a Cubit test.*

---

### Q: You open this repo. Login has no domain layer. The playbook says every data-driven feature needs one. What do you do?

**Strong answer. Nothing.** The golden rule says match the file you're editing and never refactor
unprompted. The playbook is the target for *new* code. Rewriting login would be a large unrequested diff
through the most security-sensitive flow in the app, with no tests to catch a regression. I'd note it, raise
it as a separate conversation, and build the next feature to the standard.

**Why it's correct.** This is the question I care most about, and it isn't really about architecture. It's
about whether someone can hold "this is the standard" and "that existing code doesn't meet it" in mind
simultaneously without reaching for the keyboard. Most production code is like this. Engineers who can't
tolerate it generate enormous risk.

**Common failure.** Enthusiastically proposing a migration. It's the answer that *sounds* senior and is the
least senior thing in the room.

---

### Q: Critique this workspace. What's missing or wrong?

**What I'm listening for:**

- **No tests, no test agent, no `test/` dir** — the architecture is built for testability that nothing
  exercises. The biggest gap.
- **Two of five convention checks can't fire** — they grep for `/presentation/` and `*/domain`, which don't
  exist here. The most important rules have the least automation.
- **Only one of three hooks is wired**, and the unwired one can't block anyway.
- **Nothing enforces the layer boundary at compile time** — a lint rule (`import_lint`-style) would do what
  greps and review currently do by hand.
- **The playbook describes a state the repo has never been in**, which is a real risk: an aspirational
  standard nobody has followed yet is a standard that might not survive contact.

**Common failure.** "It looks great." A senior engineer can always find the seams. Finding none means either
they didn't look or they won't tell me — both disqualifying.

---

## 10. Architectural decisions

Each major call: what was chosen, what was rejected, the trade-off, and when you'd choose differently.

### Cubit, not Bloc

- **Chosen because** events are ceremony for most screens: an event class, a handler registration, and a
  mapping, to express what a method call already expresses. Cubit is a class with methods that emits states.
- **Rejected:** Bloc (event traceability, replay, better for complex event streams); Riverpod (compile-safe,
  no service locator, excellent — and a total rewrite of the DI story); Provider (lighter, less structured);
  `setState` (no separation).
- **Trade-off:** you lose the event log. Bloc's event stream is genuinely useful for analytics and for
  debugging "how did we get to this state?"
- **Choose Bloc when** a feature has complex event choreography — debouncing, concurrent transformations, an
  audit trail. The playbook is a default, not a prohibition on thought.

### get_it service locator, not constructor injection or Riverpod

- **Chosen because** it's simple, has zero codegen, and gives one obvious composition root.
- **Trade-off — and it's the sharpest one here:** a missing registration is a **runtime** error, not a
  compile error. Riverpod would catch it at compile time. A service locator is a global mutable registry,
  which is a slightly dirty thing to have at the center of an otherwise clean architecture.
- **Choose differently when** you're starting fresh and value compile-time safety over familiarity —
  Riverpod is the stronger technical choice on that axis alone. This playbook picks team-familiarity and
  simplicity.

### freezed unions for state

- **Chosen because** exhaustive `when` means adding a state is a compile error at every call site, not a
  silent gap. Plus free equality, so Bloc's distinct-state filtering works.
- **Rejected:** hand-written state classes (equality bugs); enum + nullable fields (invalid states become
  representable — `isLoading: true` with `data` set); sealed classes (viable on Dart 3, but no free
  `copyWith`/equality).
- **Trade-off:** build_runner. Every state edit costs a codegen cycle, and it is not fast.
- **Note:** Dart 3 sealed classes + pattern matching now cover much of this natively. If you were starting
  today, that's a real conversation.

### Retrofit over hand-written Dio calls

- **Chosen because** the endpoint becomes a typed method signature; parsing is generated, so hand-written
  `fromJson` plumbing disappears.
- **Trade-off:** more codegen; harder to do dynamic request shaping; generated errors can be opaque.

### The domain layer + use cases

- **Chosen because** it decouples presentation from data, makes Cubits trivially testable, and gives one
  obvious home for logic that isn't a network call.
- **Rejected:** the two-layer approach — data + presentation, Cubit calls repo directly. **Which is exactly
  what this repo does today**, and it's a legitimate, widely-used choice.
- **The honest trade-off:** for a login that just forwards, the use case is one line of delegation and three
  files of ceremony. The three-layer version costs ~5 extra files per feature. The argument for it isn't
  today's login — it's the moment login needs to also cache the profile, check a feature flag, and log an
  analytics event, at which point the use case is the obvious home and the two-layer version has to grow a
  layer under pressure.
- **Choose two-layer when:** small app, small team, thin CRUD, short horizon.
  **Choose three-layer when:** multiple teams, long-lived product, real business rules, or a backend you
  don't control and don't trust.

### Advisory hooks over blocking gates

- **Chosen because** a false positive that blocks work gets the whole hook system disabled, and then you
  have nothing.
- **Trade-off:** advisory means ignorable. `pre_commit_checks.sh` literally announces that it isn't
  blocking.
- **Choose blocking when** you have CI — that's where the teeth belong. Local hooks inform; CI enforces. The
  absence of a CI config here means *nothing is currently enforced*, which is worth knowing.

### The golden rule

- **Chosen because** an LLM's instinct is to improve everything it reads, and unrequested refactors are how
  AI-assisted development destroys trust: you asked for a button and got a 40-file diff you now have to
  review.
- **Trade-off:** the codebase stays inconsistent — which is precisely the situation this repo is in. Old
  features stay old. You accept visible divergence in exchange for reviewable diffs and no surprise
  regressions.
- **This is the right call.** Inconsistency is a known, bounded cost. An unreviewed refactor through your
  auth flow is an unbounded one.

### Committing generated files

- **Chosen because** checkout-and-run works with no codegen step, and CI doesn't need a generation stage.
- **Trade-off:** merge conflicts in generated files, and noisy diffs. The alternative — gitignore them,
  generate in CI — is also perfectly defensible and arguably cleaner.

---

## 11. Best practices

### Starting work

- **Say what you want, not how.** "Add a profile feature, GET /profile, returns name/email/photo" beats
  naming agents. Mechanism selection is the model's job — that's what the descriptions are for.
- **Bring the endpoint shape.** `create-feature` will ask; having it ready saves a round trip and prevents a
  guessed model.
- **Ask for a plan on anything non-trivial.** The gate before implementation is the cheapest place to be
  wrong.

### During

- **Read the plan.** Actually read it. This is the highest-leverage minute you'll spend.
- **Watch for the golden-rule violation.** If a diff touches a file outside the feature and outside
  `dependency_injection.dart` / `routes.dart` / `app_router.dart`, question it.
- **Don't skip build_runner.** The reminder fires for a reason.
- **Prefer the skill for known shapes, the agent for exploration.** An agent for a one-line change is pure
  overhead — cold start, re-reading files you already have.

### Before you commit

- build_runner if any annotated file changed; stage source + generated together.
- `flutter analyze` → zero *new* issues.
- `dart format` on **touched files only**. Never bulk-format — it turns a 3-file PR into a 300-file PR and
  destroys `git blame`.
- `bash .claude/hooks/validate_conventions.sh` — and ignore hits in files you didn't touch.
- **Run the app.** Analyze proves compilation, not behavior.

### Maintaining the workspace itself

- **Correct the playbook, not just the code.** If you correct the same thing twice, the playbook is wrong. A
  fix that lives only in a conversation dies with it.
- **Keep `CLAUDE.md` lean.** It costs tokens on every request forever. Depth belongs in `docs/`, loaded on
  demand. When adding, ask: does violating this cost real review time?
- **Express rules as tool restrictions when you can.** "Be surgical" in a prompt is a request; removing
  `Write` is a guarantee. Reach for the second.
- **Descriptions are the interface.** A skill with a vague description is a skill that never runs. "What it
  does. Use when `<trigger>`."
- **Keep hooks advisory and fast.** The moment one is slow or wrong, someone disables all of them.

### The three things to fix first

1. **Tests.** No `test/`, no test dependency, no test agent or skill. The architecture is shaped for
   testability nothing uses. A `test-engineer` agent + a `create-cubit-test` skill would slot straight in.
2. **Decide about the divergence, explicitly.** The playbook describes an architecture this repo has never
   used. Either commit to it for new features and let the split be deliberate and documented, or relax the
   playbook to match the two-layer reality. The one bad option is leaving it ambiguous — a standard nobody
   follows teaches people that standards are decoration.
3. **Wire something with teeth.** Nothing currently blocks anything. CI running `flutter analyze` +
   build_runner freshness would make the advisory layer meaningful, because advice you can ignore forever
   isn't a standard.

---

## The one idea to take away

This workspace is **four enforcement mechanisms of ascending strength**, and knowing which is which is the
whole game:

| Mechanism | What it does | Where it lives | Strength |
|---|---|---|---|
| **Documentation** | Persuades | `CLAUDE.md`, `docs/` | Weakest — depends on attention |
| **Procedure** | Makes the right thing easy | skills, commands | Depends on selection |
| **Capability** | Makes the wrong thing impossible | agent `tools:` frontmatter | Enforced by the runtime |
| **Automation** | Catches what slipped | hooks | Doesn't need the model's cooperation at all |

When you add to this system, ask which layer your rule belongs in. Most people reach for documentation
because it's easiest to write. **The strong moves are the other three.**
