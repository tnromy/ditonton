#!/usr/bin/env bash
# Runs the unit & widget tests of every module and merges their coverage into
# coverage/lcov.info. Fails when total line coverage is below MIN_COVERAGE.
set -euo pipefail

MIN_COVERAGE="${MIN_COVERAGE:-95}"
PACKAGES=(core about movie tv .)

root="$(cd "$(dirname "$0")" && pwd)"
cd "$root"
merged="$(mktemp)"
trap 'rm -f "$merged"' EXIT

for pkg in "${PACKAGES[@]}"; do
  echo "::group::flutter test $pkg"
  (cd "$pkg" && flutter test --coverage --no-pub)
  echo "::endgroup::"

  prefix=""
  [ "$pkg" != "." ] && prefix="$pkg/"
  # keep only the package's own lib/ files and make their paths repo-relative
  awk -v p="$prefix" '
    /^SF:/ { keep = ($0 ~ /^SF:lib\//); if (keep) sub(/^SF:/, "SF:" p) }
    keep
  ' "$pkg/coverage/lcov.info" >> "$merged"
done

cp "$merged" coverage/lcov.info

awk -F: -v min="$MIN_COVERAGE" '
  /^LF:/ { found += $2 }
  /^LH:/ { hit += $2 }
  END {
    pct = hit * 100 / found
    printf "Total line coverage: %.2f%% (%d/%d lines)\n", pct, hit, found
    if (pct < min) { printf "Coverage is below %s%%\n", min; exit 1 }
  }
' coverage/lcov.info
