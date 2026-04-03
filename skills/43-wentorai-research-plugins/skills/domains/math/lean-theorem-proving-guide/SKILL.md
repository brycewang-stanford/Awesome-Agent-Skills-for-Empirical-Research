---
name: lean-theorem-proving-guide
description: "LLM agent for formal theorem proving in Lean 4"
metadata:
  openclaw:
    emoji: "📐"
    category: "domains"
    subcategory: "math"
    keywords: ["Lean 4", "theorem proving", "formal verification", "LLM math", "proof assistant", "LeanAgent"]
    source: "https://github.com/lean-dojo/LeanAgent"
---

# Lean Theorem Proving Agent Guide

## Overview

LeanAgent is an LLM-based agent for automated theorem proving in Lean 4, a modern proof assistant. It combines LLM reasoning with formal verification — proposing proof steps that are verified by Lean's type checker. Can prove novel theorems, not just benchmarks, by exploring proof strategies, backtracking on failures, and learning from successful proofs.

## Architecture

```
Theorem Statement (Lean 4)
         ↓
   Goal Analysis Agent (understand proof obligations)
         ↓
   Tactic Suggestion Agent (propose proof steps)
         ↓
   Lean 4 Verification (check tactic correctness)
         ↓
   Backtracking (if tactic fails, try alternatives)
         ↓
   Proof or timeout
```

## Usage

```python
from lean_agent import LeanAgent

agent = LeanAgent(
    llm_provider="anthropic",
    lean_path="/path/to/lean4",
)

# Prove a theorem
result = agent.prove(
    theorem="""
    theorem add_comm (m n : Nat) : m + n = n + m := by
      sorry
    """,
    max_attempts=50,
    timeout=120,
)

if result.proved:
    print("Proof found!")
    print(result.proof)
else:
    print(f"Failed. Best attempt:\n{result.best_attempt}")
    print(f"Remaining goals: {result.remaining_goals}")
```

## Proof Search Strategies

```python
# Configure search strategy
agent = LeanAgent(
    search_config={
        "strategy": "best_first",   # best_first, bfs, dfs
        "max_depth": 20,            # Max proof steps
        "beam_width": 5,            # Tactics to try per step
        "temperature": 0.7,         # LLM sampling temp
        "backtrack_on_fail": True,
    },
)

# Interactive proof mode
session = agent.interactive_prove(
    theorem="theorem my_thm : ∀ n : Nat, n + 0 = n := by"
)

while not session.done:
    print(f"Current goals:\n{session.goals}")
    tactics = session.suggest_tactics(k=5)
    for i, t in enumerate(tactics):
        print(f"  {i}: {t.tactic} (confidence: {t.score:.2f})")
    # Agent automatically picks best tactic
    session.step()
```

## Lean 4 Tactic Library

```lean
-- Common tactics LeanAgent uses:
-- intro, apply, exact, rfl, simp, omega
-- induction, cases, constructor, ext
-- rw, calc, have, let, show

-- Example theorem + proof
theorem list_append_nil (l : List α) : l ++ [] = l := by
  induction l with
  | nil => simp
  | cons h t ih => simp [ih]
```

## Batch Proving

```python
# Prove multiple theorems
theorems = [
    "theorem t1 : 1 + 1 = 2 := by sorry",
    "theorem t2 (n : Nat) : n + 0 = n := by sorry",
    "theorem t3 (n m : Nat) : n + m = m + n := by sorry",
]

results = agent.prove_batch(
    theorems=theorems,
    parallel=True,
    timeout_per=60,
)

for thm, result in zip(theorems, results):
    status = "PROVED" if result.proved else "FAILED"
    print(f"[{status}] {thm[:50]}...")
```

## Use Cases

1. **Automated proving**: Prove mathematical theorems formally
2. **Proof assistance**: Suggest tactics during manual proving
3. **Verification**: Formally verify mathematical claims
4. **Education**: Learn Lean 4 tactics with AI guidance
5. **Research**: Explore new proof techniques

## References

- [LeanAgent GitHub](https://github.com/lean-dojo/LeanAgent)
- [Lean 4](https://lean-lang.org/)
- [Mathlib4](https://leanprover-community.github.io/mathlib4_docs/)
- [LeanDojo](https://leandojo.org/)
