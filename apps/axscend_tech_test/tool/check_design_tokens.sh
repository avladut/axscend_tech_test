#!/usr/bin/env bash
# Design-token check: feature code must take colours, text sizes, spacing and
# radii from packages/app_ui, never hard-code them. Only lib/ is scanned,
# because packages/app_ui is where those values are allowed to live.
#
# Usage (from anywhere inside the app):
#   tool/check_design_tokens.sh               # whole of lib/ (new apps)
#   tool/check_design_tokens.sh --diff dev    # only lines added since branch "dev"
#                                             # (apps that already have hard-coded values)
#
# A genuine one-off can opt out by ending the line with:
#   // design-token-ok: <reason>
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root"

# Hard-coded colours, text sizes, inline text styles, numeric radii,
# numeric padding/margins and numeric spacers. `Colors.` must not follow an
# identifier character, so `context.appColors.primary` and
# `AppColors.fallback` are not mistaken for Material's `Colors.x`.
pattern='Color\(0x|(^|[^A-Za-z0-9_])Colors\.[a-z]|fontSize:|TextStyle\(|Radius\.circular\([0-9.]|EdgeInsets\.[A-Za-z]+\([^)]*[0-9]|SizedBox\((height|width): *[0-9]'

filter() {
  grep -E "$pattern" |
    grep -v '\.g\.dart:' |
    grep -v 'Colors\.transparent' |
    grep -v 'design-token-ok' || true
}

if [[ "${1:-}" == "--diff" ]]; then
  base="${2:?usage: --diff <base-ref>}"
  # Added lines only, printed as file:line:code. Covers committed and
  # uncommitted changes to tracked files; new files need a git add first.
  hits="$(git diff -U0 "$base" -- 'lib/*.dart' |
    awk '
      /^\+\+\+ b\// { file = substr($0, 7); next }
      /^\+\+\+/     { file = ""; next }
      /^@@/         { split($3, a, /[+,]/); line = a[2]; next }
      /^\+/         { if (file != "") print file ":" line ":" substr($0, 2); line++ }
    ' | filter)"
  scope="lines added since $base"
else
  # grep exits 1 on a clean lib/; under pipefail that must not end the
  # script, so it is fenced off with || true.
  hits="$({ grep -rnE --include='*.dart' "$pattern" lib 2>/dev/null || true; } | filter)"
  scope="lib/"
fi

if [[ -z "$hits" ]]; then
  echo "Design tokens: OK ($scope)"
  exit 0
fi

echo "$hits"
echo
count="$(printf '%s\n' "$hits" | wc -l | tr -d ' ')"
echo "Design tokens: $count hard-coded value(s) in $scope."
echo "Use the tokens and components from packages/app_ui instead (see its DESIGN.md)."
exit 1
