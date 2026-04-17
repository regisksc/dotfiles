# Testing — dry-run safety & secret leak checks

## 1. Verify dry-run touches nothing

Run this before and after `--dry-run` to confirm zero file changes:

```bash
# snapshot mtimes of sensitive targets before
before=$(stat -f "%m %N" \
  ~/.zshrc ~/.gitconfig ~/.tmux.conf \
  ~/.claude/settings.json \
  ~/.config/opencode/opencode.json \
  ~/.config/opencode/mcp.json \
  ~/.config/goose/config.yaml \
  ~/.cursor/mcp.json \
  ~/.gemini/antigravity/settings.json \
  2>/dev/null | sort)

./install.sh install --dry-run --yes

after=$(stat -f "%m %N" \
  ~/.zshrc ~/.gitconfig ~/.tmux.conf \
  ~/.claude/settings.json \
  ~/.config/opencode/opencode.json \
  ~/.config/opencode/mcp.json \
  ~/.config/goose/config.yaml \
  ~/.cursor/mcp.json \
  ~/.gemini/antigravity/settings.json \
  2>/dev/null | sort)

if [ "$before" = "$after" ]; then
  echo "✓ PASS: dry-run changed nothing"
else
  echo "✗ FAIL: files were modified during dry-run"
  diff <(echo "$before") <(echo "$after")
fi
```

## 2. Secret leak scan (fast)

```bash
./install.sh sync   # runs secret_scan internally, exits 1 on hit
```

Or run the scanner directly against any path:

```bash
bash -c '
  source ~/Git/dotfiles/lib/logging.sh
  source ~/Git/dotfiles/lib/os.sh
  source ~/Git/dotfiles/lib/secrets.sh
  LOG_FILE=/dev/null ACTION_LOG=/dev/null _VERBOSE=false
  detect_os
  init_logging /tmp /tmp false
  secret_scan ~/Git/dotfiles
'
```

## 3. Verify no raw API keys in templates

```bash
# Should print nothing
grep -rn \
  -e 'sk-sp-[A-Za-z0-9]\{10,\}' \
  -e 'sk-[A-Za-z0-9]\{32,\}' \
  -e 'AKIA[0-9A-Z]\{16\}' \
  -e 'ghp_[A-Za-z0-9]\{36\}' \
  ~/Git/dotfiles \
  --exclude-dir=backups \
  --exclude-dir=logs \
  --exclude-dir=state \
  --exclude-dir=.git \
  --exclude='.env.local'
echo "exit $? (0 = clean)"
```

## 4. Verify .zshrc template is clean

```bash
python3 -c "
import re, sys
with open('$HOME/Git/dotfiles/shell/templates/.zshrc.tmpl') as f:
    content = f.read()
hits = re.findall(r'sk-[A-Za-z0-9_-]{20,}', content)
if hits:
    print('FAIL — raw keys found:', hits)
    sys.exit(1)
else:
    print('PASS — no raw keys in .zshrc.tmpl')
"
```

## 5. Verify rendered templates don't corrupt JSON

After `./install.sh install`, verify key JSON configs parse correctly:

```bash
for f in \
  ~/.config/opencode/opencode.json \
  ~/.config/opencode/mcp.json \
  ~/.config/opencode/config.json \
  ~/.cursor/mcp.json \
  ~/.gemini/antigravity/settings.json; do
  python3 -c "import json; json.load(open('$f')); print('OK: $f')" 2>/dev/null \
    || echo "FAIL: $f"
done
```
