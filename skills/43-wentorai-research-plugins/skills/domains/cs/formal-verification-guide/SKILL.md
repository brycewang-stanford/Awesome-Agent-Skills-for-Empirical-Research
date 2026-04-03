---
name: formal-verification-guide
description: "Formal methods, theorem proving, and model checking for CS research"
metadata:
  openclaw:
    emoji: "✅"
    category: "domains"
    subcategory: "cs"
    keywords: ["formal-verification", "theorem-proving", "model-checking", "tla-plus", "coq", "isabelle"]
    source: "wentor"
---

# Formal Verification Guide

A skill for applying formal methods to verify software and hardware correctness. Covers model checking, interactive theorem proving, specification languages, and practical verification workflows used in systems and programming language research.

## Verification Approaches Overview

### Methods Comparison

| Approach | Technique | Strengths | Limitations |
|----------|-----------|-----------|-------------|
| Model checking | Exhaustive state exploration | Fully automatic, produces counterexamples | State space explosion |
| Theorem proving | Interactive proof construction | Handles infinite state | Requires expert effort |
| Abstract interpretation | Sound static analysis | Automatic, scales well | May report false positives |
| SMT solving | Constraint satisfiability | Powerful automation | Limited to decidable theories |
| Runtime verification | Execution monitoring | Low barrier, practical | Only checks observed runs |

## TLA+ Specification

### Specifying Distributed Protocols

TLA+ is the standard specification language for distributed systems:

```tla
--------------------------- MODULE TwoPhaseCommit -------------------------
EXTENDS Integers, Sequences, FiniteSets

CONSTANTS RM  \* Set of resource managers

VARIABLES
    rmState,      \* rmState[r] is the state of resource manager r
    tmState,      \* State of the transaction manager
    tmPrepared,   \* Set of RMs that have sent "Prepared"
    msgs          \* Set of messages sent

vars == <<rmState, tmState, tmPrepared, msgs>>

Init ==
    /\ rmState = [r \in RM |-> "working"]
    /\ tmState = "init"
    /\ tmPrepared = {}
    /\ msgs = {}

\* RM r prepares to commit
RMPrepare(r) ==
    /\ rmState[r] = "working"
    /\ rmState' = [rmState EXCEPT ![r] = "prepared"]
    /\ msgs' = msgs \union {[type |-> "Prepared", rm |-> r]}
    /\ UNCHANGED <<tmState, tmPrepared>>

\* TM receives a Prepared message from RM r
TMRcvPrepared(r) ==
    /\ tmState = "init"
    /\ [type |-> "Prepared", rm |-> r] \in msgs
    /\ tmPrepared' = tmPrepared \union {r}
    /\ UNCHANGED <<rmState, tmState, msgs>>

\* TM commits (all RMs have prepared)
TMCommit ==
    /\ tmState = "init"
    /\ tmPrepared = RM
    /\ tmState' = "committed"
    /\ msgs' = msgs \union {[type |-> "Commit"]}
    /\ UNCHANGED <<rmState, tmPrepared>>

\* Safety property: No RM commits unless TM has committed
Consistency ==
    \A r \in RM : rmState[r] = "committed" => tmState = "committed"
========================================================================
```

### Running the TLC Model Checker

```bash
# Install TLA+ Toolbox or use command-line TLC
# Define model with specific constants
# RM = {"rm1", "rm2", "rm3"}
java -jar tla2tools.jar -config TwoPhaseCommit.cfg TwoPhaseCommit.tla

# TLC will explore all reachable states and verify:
# - No deadlocks (unless specified)
# - Safety properties (invariants)
# - Liveness properties (temporal formulas)
```

## Interactive Theorem Proving

### Coq Proof Assistant

```coq
(* Example: Proving properties of a simple functional program *)

(* Define natural number addition *)
Fixpoint add (n m : nat) : nat :=
  match n with
  | O => m
  | S n' => S (add n' m)
  end.

(* Prove: 0 + n = n (left identity) *)
Theorem add_0_l : forall n : nat, add 0 n = n.
Proof.
  intro n.
  simpl.    (* simplification reduces add 0 n to n *)
  reflexivity.
Qed.

(* Prove: n + 0 = n (right identity, requires induction) *)
Theorem add_0_r : forall n : nat, add n 0 = n.
Proof.
  intro n.
  induction n as [| n' IHn'].
  - (* Base case: n = 0 *)
    simpl. reflexivity.
  - (* Inductive step: n = S n' *)
    simpl.               (* add (S n') 0 = S (add n' 0) *)
    rewrite IHn'.        (* apply induction hypothesis *)
    reflexivity.
Qed.

(* Prove associativity of addition *)
Theorem add_assoc : forall a b c : nat,
  add a (add b c) = add (add a b) c.
Proof.
  intros a b c.
  induction a as [| a' IHa'].
  - simpl. reflexivity.
  - simpl. rewrite IHa'. reflexivity.
Qed.
```

### Isabelle/HOL

```isabelle
theory SimpleVerification
  imports Main
begin

(* Define a recursive function *)
fun fib :: "nat => nat" where
  "fib 0 = 0"
| "fib (Suc 0) = 1"
| "fib (Suc (Suc n)) = fib (Suc n) + fib n"

(* Prove a property *)
lemma fib_positive: "0 < fib (Suc n)"
  by (induction n rule: fib.induct) auto

(* Verify a sorting algorithm *)
fun insert :: "nat => nat list => nat list" where
  "insert x [] = [x]"
| "insert x (y # ys) = (if x <= y then x # y # ys else y # insert x ys)"

fun isort :: "nat list => nat list" where
  "isort [] = []"
| "isort (x # xs) = insert x (isort xs)"

(* Prove the output is sorted *)
lemma sorted_insert: "sorted (insert x xs) = sorted xs"
  sorry (* full proof requires additional lemmas *)

end
```

## SMT Solving

### Z3 for Program Verification

```python
from z3 import Solver, Int, Bool, And, Or, Not, Implies, ForAll, sat, unsat

def verify_array_bounds():
    """
    Verify that an array access is always within bounds.
    Model a loop: for i = 0 to n-1, access a[i].
    """
    s = Solver()
    n = Int("n")
    i = Int("i")

    # Precondition: n > 0
    s.add(n > 0)

    # Loop invariant: 0 <= i < n at each access
    s.add(i >= 0)
    s.add(i < n)

    # Verify: the access a[i] is within bounds [0, n)
    s.add(Not(And(i >= 0, i < n)))  # try to find a violation

    result = s.check()
    if result == unsat:
        return "VERIFIED: array access is always within bounds"
    else:
        return f"COUNTEREXAMPLE: {s.model()}"

def verify_integer_overflow():
    """
    Check if integer addition can overflow for given constraints.
    """
    from z3 import BitVec, BitVecVal

    s = Solver()
    # 32-bit signed integers
    x = BitVec("x", 32)
    y = BitVec("y", 32)

    # Preconditions: both positive
    s.add(x > 0)
    s.add(y > 0)

    # Check: can x + y wrap around to negative?
    s.add(x + y < 0)

    if s.check() == sat:
        m = s.model()
        return {
            "overflow_possible": True,
            "x": m[x].as_long(),
            "y": m[y].as_long(),
        }
    return {"overflow_possible": False}
```

## Model Checking with SPIN

### Promela Specification

```promela
/* Mutual exclusion with Peterson's algorithm */
bool flag[2] = false;
byte turn = 0;
byte critical = 0;  /* count of processes in critical section */

active [2] proctype process() {
    byte me = _pid;
    byte other = 1 - _pid;

    do
    :: /* Entry protocol */
       flag[me] = true;
       turn = other;
       (flag[other] == false || turn == me);

       /* Critical section */
       critical++;
       assert(critical == 1);  /* mutual exclusion */
       critical--;

       /* Exit protocol */
       flag[me] = false;
    od
}

/* LTL property: mutual exclusion always holds */
ltl mutex { [] (critical <= 1) }
```

## Verification Workflow

### Practical Verification Strategy

1. **Specify**: Write a formal specification of the desired property
2. **Model**: Create an abstract model of the system
3. **Verify**: Run model checker or construct proof
4. **Refine**: If counterexample found, fix the design or refine the model
5. **Extract**: Generate verified code from the proof (Coq extraction, Isabelle code generation)

### Common Properties to Verify

| Property Type | Example | Specification Pattern |
|--------------|---------|----------------------|
| Safety | "No two processes in critical section" | `[] (count <= 1)` |
| Liveness | "Every request is eventually served" | `[] (request -> <> response)` |
| Deadlock freedom | "System always has an enabled transition" | `[] <> enabled` |
| Termination | "Program always halts" | Well-founded ordering |

## Tools and Resources

- **TLA+ Toolbox**: IDE for TLA+ with integrated TLC model checker
- **Coq**: Interactive theorem prover with program extraction
- **Isabelle/HOL**: Higher-order logic prover with Sledgehammer automation
- **Z3 / CVC5**: SMT solvers for automated reasoning
- **SPIN**: Model checker for concurrent systems (Promela)
- **CBMC**: Bounded model checker for C programs
- **Dafny**: Verification-aware programming language (Microsoft)
- **Lean 4**: Modern theorem prover and programming language
