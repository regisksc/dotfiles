# iOS Hooks

## PostToolUse Hooks

Run `swiftformat` after Swift file edits:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "jq -r '.tool_input.file_path // .tool_response.filePath' | { read -r f; echo \"$f\" | grep -qE '\\.swift$' && swiftformat \"$f\" 2>/dev/null || true; }"
          }
        ]
      }
    ]
  }
}
```

## References

See `swift/hooks.md` for Swift-specific hook patterns.
See common hooks for baseline hook patterns.
