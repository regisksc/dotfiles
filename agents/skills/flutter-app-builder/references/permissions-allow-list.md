# Flutter Dev Permissions Allow List

Use `update-config` skill to add these to `settings.local.json` at project start.

## Allow List Entries

```json
"Bash(flutter *:*)",
"Bash(fvm *:*)",
"Bash(dart *:*)",
"Bash(ls *:*)",
"Bash(ls)",
"Bash(cat *:*)",
"Bash(awk *:*)",
"Bash(grep *:*)",
"Bash(sed *:*)",
"Bash(find *:*)",
"Bash(wc *:*)",
"Bash(head *:*)",
"Bash(tail *:*)",
"Bash(sort *:*)",
"Bash(uniq *:*)",
"Bash(echo *:*)",
"Bash(cd *:*)",
"Bash(mkdir *:*)",
"Bash(rm *:*)",
"Bash(mv *:*)",
"Bash(cp *:*)",
"Bash(touch *:*)",
"Bash(chmod *:*)",
"Bash(which *:*)",
"Bash(env *:*)",
"Bash(python3 *:*)",
"Bash(rtk *:*)",
"Bash(git status:*)",
"Bash(git log:*)",
"Bash(git diff:*)",
"Bash(git add:*)",
"Bash(git commit:*)",
"Bash(git branch:*)",
"Bash(git checkout:*)",
"Bash(git fetch:*)",
"Bash(git pull:*)",
"Bash(git stash:*)",
"Bash(git show:*)"
```

## What is intentionally excluded

- `git push` — requires explicit user request (affects remote)
- `git reset --hard` — destructive, requires explicit request
- `git rebase` — requires explicit request
- `brew install` — system-level, requires explicit request
- `rm -rf /` and variants — never allowed
