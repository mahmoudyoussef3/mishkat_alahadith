#!/usr/bin/env bash
# Manual convention validator — Flutter Engineering Playbook
# Scans lib/ for common convention violations and prints a report. Read-only; never edits code.
# Run directly:  bash .claude/hooks/validate_conventions.sh
# Intended as an advisory checklist, NOT a hard gate. Pre-existing files you shouldn't touch are ignored.

set -uo pipefail
cd "$(git rev-parse --show-toplevel 2>/dev/null || echo .)"

LIB="lib"
issues=0
note() { printf '  - %s\n' "$1"; issues=$((issues+1)); }

echo "== Flutter convention check =="

echo "[1] Direct Navigator.of(...) usage (prefer context.pushNamed / context.pop extension):"
grep -rn "Navigator.of(context)" "$LIB" --include="*.dart" 2>/dev/null \
  | grep -v "core/helpers/extensions.dart" \
  | while read -r line; do note "$line"; done || true

echo "[2] Raw Dio() construction outside DioFactory (use DioFactory.getDio()):"
grep -rnE "\bDio\(\)" "$LIB" --include="*.dart" 2>/dev/null \
  | grep -v "core/networking/dio_factory.dart" \
  | while read -r line; do note "$line"; done || true

echo "[3] Hardcoded Color( literals in widgets (prefer ColorsManager):"
grep -rn "Color(0x" "$LIB" --include="*.dart" 2>/dev/null \
  | grep -v "core/theming/colors.dart" \
  | while read -r line; do note "$line"; done || true

echo "[4] Presentation layer importing data/ (new-feature boundary violation):"
grep -rn "import .*/data/" "$LIB/features" --include="*.dart" 2>/dev/null \
  | grep "/presentation/" \
  | while read -r line; do note "$line"; done || true

echo "[5] Domain layer importing Flutter/Dio/Retrofit/json (should be pure Dart):"
grep -rnE "import 'package:(flutter|dio|retrofit|json_annotation)/" "$LIB/features"/*/domain 2>/dev/null \
  | while read -r line; do note "$line"; done || true

echo
echo "Note: this is advisory. Some hits may be in pre-existing files you shouldn't touch — do NOT refactor them."
echo "Done."
exit 0
