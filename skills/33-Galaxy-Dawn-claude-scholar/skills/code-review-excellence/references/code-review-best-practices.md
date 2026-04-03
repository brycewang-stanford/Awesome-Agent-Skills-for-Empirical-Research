# Code Review Best Practices

## Default review order
1. Understand intent and scope.
2. Check architecture and correctness.
3. Check tests and failure handling.
4. Check security and performance risks.
5. Leave clear, prioritized comments.

## Comment severity
- `blocking` - correctness, security, data loss, major maintainability issue
- `important` - should be fixed before merge if practical
- `nit` - polish only

## Good reviewer habits
- summarize first,
- separate required changes from suggestions,
- quote the code path or failure mode,
- praise good decisions when they matter.
