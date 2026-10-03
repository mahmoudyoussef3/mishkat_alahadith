---
description: Review the current changes/feature against the playbook conventions and architecture (report only).
argument-hint: [feature name or leave blank to review the working diff]
---

Review $ARGUMENTS against the playbook conventions. If no argument is given, review the current working diff.

Follow the `review-feature` skill and `.claude/docs/CHECKLISTS.md`:
1. `git status` and `git diff --stat` to scope the review; read the changed files and their feature.
2. Check: layer boundaries, Cubit/State conventions, `ApiResult` in repos, `buildWhen`/`listenWhen`,
   theming tokens (no hardcoded colors/styles/URLs/pixels), navigation via extension, DI registration,
   models/codegen freshness, naming/structure.
3. Run `flutter analyze` and include its status.

Output a prioritized findings list (**Must fix** vs **Nice to have**) with `file:line` references and a
concrete fix for each. **Do not edit any code.** Do not flag intentional-looking pre-existing patterns in
untouched files (`.claude/docs/CONVENTIONS.md` §Respecting existing code) as defects.
