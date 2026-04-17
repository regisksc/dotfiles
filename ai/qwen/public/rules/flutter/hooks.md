# Flutter Hooks

## PostToolUse Hooks

Run `dart format` and analysis after file edits:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "jq -r '.tool_input.file_path // .tool_response.filePath' | { read -r f; echo \"$f\" | grep -qE '\\.dart$' && dart format \"$f\" 2>/dev/null || true; }"
          }
        ]
      }
    ]
  }
}
```

## References

See common hooks for baseline hook patterns.
