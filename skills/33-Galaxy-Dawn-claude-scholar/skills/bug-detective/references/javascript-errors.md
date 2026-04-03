# JavaScript / TypeScript Error Guide

## Frequent failure classes
- `TypeError` from undefined/null access
- async error swallowing in `Promise` chains
- `this` binding mismatches
- stale closure bugs in hooks or event handlers
- ESM / CJS import mismatches

## Minimum debugging flow
1. copy the full stack trace,
2. identify whether the failure is runtime, bundler, or type-level,
3. confirm the failing object/value before changing logic,
4. reproduce with the smallest possible input.
