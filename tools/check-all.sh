#!/usr/bin/env bash
# Runs every check for a milestone and prints a short summary. Usage: tools/check-all.sh [--no-apk]
# Windows (Git Bash): uses mvnw.cmd and the JDK 21 / Flutter / Android SDK paths set up on this machine.
set -u
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
export JAVA_HOME="${JAVA_HOME_21:-C:\Users\shero\.jdks\openjdk-21.0.2}"
export ANDROID_HOME="${ANDROID_HOME:-C:\Users\shero\AppData\Local\Android\Sdk}"
export PATH="/c/Users/shero/dev/flutter/bin:$PATH"
LOG="${TMPDIR:-/tmp}/tranix-check"; mkdir -p "$LOG"
ok=0

cd "$ROOT/backend"
if [ -f mvnw.cmd ] && command -v cmd >/dev/null 2>&1; then cmd //c ".\mvnw.cmd -q -B verify" > "$LOG/backend.log" 2>&1; else ./mvnw -q -B verify > "$LOG/backend.log" 2>&1; fi
b=$?; if [ $b -eq 0 ]; then echo "backend verify: OK"; else ok=1; echo "backend verify: FAILED"; grep -E "Tests run:.*Fail|ERROR\]   |ERROR\] /" "$LOG/backend.log" | cut -c1-220 | head -15; fi

cd "$ROOT/frontend"
flutter analyze > "$LOG/analyze.log" 2>&1; a=$?
if grep -q "No issues found" "$LOG/analyze.log"; then echo "flutter analyze: OK"; else ok=1; echo "flutter analyze: ISSUES"; grep -E " - " "$LOG/analyze.log" | head -15; fi
flutter test > "$LOG/test.log" 2>&1
if tail -1 "$LOG/test.log" | grep -q "All tests passed"; then echo "flutter test: $(tail -1 "$LOG/test.log" | grep -oE '\+[0-9]+' | tail -1) passed"; else ok=1; echo "flutter test: FAILED"; grep -E "Expected|Actual|Error:|\[E\]" "$LOG/test.log" | head -15; fi

if [ "${1:-}" != "--no-apk" ]; then
  flutter build apk --debug > "$LOG/apk.log" 2>&1
  if grep -q "Built build" "$LOG/apk.log"; then echo "debug apk: OK"; else ok=1; echo "debug apk: FAILED"; grep -E "What went wrong" -A3 "$LOG/apk.log" | head -8; fi
fi
exit $ok
