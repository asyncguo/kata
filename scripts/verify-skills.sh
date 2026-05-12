#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel 2>/dev/null || dirname "$0"/..)"

errors=0

check_frontmatter() {
  local file="$1"
  local name desc version

  if ! head -1 "$file" | grep -q '^---$'; then
    echo "ERROR: INVALID FRONTMATTER: $file (missing opening ---)" >&2
    errors=$((errors + 1))
    return
  fi

  local end_line
  end_line=$(tail -n +2 "$file" | grep -n '^---$' | head -1 | cut -d: -f1)
  if [ -z "$end_line" ]; then
    echo "ERROR: INVALID FRONTMATTER: $file (missing closing ---)" >&2
    errors=$((errors + 1))
    return
  fi

  local front
  front=$(head -n $((end_line + 1)) "$file")

  name=$(echo "$front" | grep '^name:' | head -1 | sed 's/^name:[[:space:]]*//' | tr -d '"')
  desc=$(echo "$front" | grep '^description:' | head -1)
  version=$(echo "$front" | grep 'version:' | head -1 | sed 's/.*version:[[:space:]]*//' | tr -d '"')

  if [ -z "$name" ]; then
    echo "ERROR: MISSING FIELD 'name': $file" >&2
    errors=$((errors + 1))
  fi
  if [ -z "$desc" ]; then
    echo "ERROR: MISSING FIELD 'description': $file" >&2
    errors=$((errors + 1))
  fi
  if [ -z "$version" ]; then
    echo "ERROR: MISSING FIELD 'version': $file" >&2
    errors=$((errors + 1))
  fi

  echo "  $file: name=$name version=$version"
}

check_marketplace() {
  local manifest=".claude-plugin/marketplace.json"
  if [ ! -f "$manifest" ]; then
    echo "ERROR: MISSING $manifest" >&2
    errors=$((errors + 1))
    return
  fi

  if ! python3 -c "import json; json.load(open('$manifest'))" 2>/dev/null; then
    echo "ERROR: INVALID JSON: $manifest" >&2
    errors=$((errors + 1))
    return
  fi

  local entries
  entries=$(python3 -c "
import json
data = json.load(open('$manifest'))
for p in data.get('plugins', []):
    src = p.get('source', '')
    name = p.get('name', '')
    version = p.get('version', '')
    print(f'{name}|{src}|{version}')
")

  while IFS='|' read -r pname psrc pversion; do
    if [ -n "$psrc" ] && [ "$psrc" != "./" ]; then
      if [ ! -d "$psrc" ]; then
        local skill_name
        skill_name=$(basename "$psrc")
        echo "ERROR: MISSING SKILL DIRECTORY: $skill_name (source: $psrc)" >&2
        errors=$((errors + 1))
      fi
    fi
    echo "  marketplace: $pname v$pversion -> $psrc"
  done <<< "$entries"
}

echo "=== Checking SKILL.md frontmatter ==="
for skill_file in skills/*/SKILL.md; do
  if [ -f "$skill_file" ]; then
    check_frontmatter "$skill_file"
  fi
done

echo ""
echo "=== Checking marketplace.json ==="
check_marketplace

echo ""
if [ "$errors" -gt 0 ]; then
  echo "FAILED: $errors error(s) found" >&2
  exit 1
else
  echo "OK: all checks passed"
fi
