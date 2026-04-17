# Android Hooks

## PostToolUse Hooks

Run `ktlint` after Kotlin file edits:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "jq -r '.tool_input.file_path // .tool_response.filePath' | { read -r f; echo \"$f\" | grep -qE '\\.kt$' && ktlint --format \"$f\" 2>/dev/null || true; }"
          }
        ]
      }
    ]
  }
}
```

## References

See `kotlin/hooks.md` for Kotlin-specific hook patterns.
See common hooks for baseline hook patterns.
