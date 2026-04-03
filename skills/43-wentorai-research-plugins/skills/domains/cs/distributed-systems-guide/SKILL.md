---
name: distributed-systems-guide
description: "Distributed systems design patterns and analysis for CS research"
metadata:
  openclaw:
    emoji: "🌐"
    category: "domains"
    subcategory: "cs"
    keywords: ["distributed-systems", "consensus", "replication", "fault-tolerance", "scalability", "cap-theorem"]
    source: "wentor"
---

# Distributed Systems Guide

A skill for researching and designing distributed systems, covering consensus algorithms, replication strategies, consistency models, fault tolerance, and performance analysis. Provides theoretical foundations and practical implementations relevant to systems research.

## Consistency Models

### Consistency Hierarchy

```
Strongest
  |  Linearizability (atomic, real-time ordering)
  |  Sequential consistency (program order respected)
  |  Causal consistency (causally related ops ordered)
  |  PRAM / FIFO consistency (per-process order)
  |  Eventual consistency (converges if updates stop)
Weakest
```

### CAP Theorem and PACELC

The CAP theorem states that during a network partition, a distributed system must choose between consistency and availability:

| System | Partition Behavior | Normal Behavior | Classification |
|--------|-------------------|----------------|----------------|
| ZooKeeper | Consistent (sacrifice A) | Low latency, consistent | CP / PC/EC |
| Cassandra | Available (sacrifice C) | Low latency, eventual | AP / PA/EL |
| Spanner | Consistent (sacrifice A) | Higher latency, consistent | CP / PC/EC |
| DynamoDB | Configurable per-read | Tunable consistency | AP or CP |
| CockroachDB | Consistent (sacrifice A) | Serializable | CP / PC/EC |

## Consensus Algorithms

### Raft Implementation Sketch

```python
from enum import Enum
from dataclasses import dataclass, field
import random

class NodeState(Enum):
    FOLLOWER = "follower"
    CANDIDATE = "candidate"
    LEADER = "leader"

@dataclass
class LogEntry:
    term: int
    index: int
    command: str

@dataclass
class RaftNode:
    """
    Simplified Raft consensus node for educational purposes.
    Implements leader election and log replication state machine.
    """
    node_id: str
    state: NodeState = NodeState.FOLLOWER
    current_term: int = 0
    voted_for: str = None
    log: list = field(default_factory=list)
    commit_index: int = 0
    last_applied: int = 0

    # Leader state
    next_index: dict = field(default_factory=dict)
    match_index: dict = field(default_factory=dict)

    def start_election(self, peers: list[str]) -> dict:
        """Transition to candidate and request votes."""
        self.state = NodeState.CANDIDATE
        self.current_term += 1
        self.voted_for = self.node_id

        last_log_index = len(self.log) - 1 if self.log else -1
        last_log_term = self.log[-1].term if self.log else 0

        return {
            "type": "RequestVote",
            "term": self.current_term,
            "candidate_id": self.node_id,
            "last_log_index": last_log_index,
            "last_log_term": last_log_term,
        }

    def handle_vote_request(self, term: int, candidate_id: str,
                              last_log_index: int,
                              last_log_term: int) -> dict:
        """Process a RequestVote RPC."""
        if term < self.current_term:
            return {"term": self.current_term, "vote_granted": False}

        if term > self.current_term:
            self.current_term = term
            self.state = NodeState.FOLLOWER
            self.voted_for = None

        # Check if candidate's log is at least as up-to-date
        my_last_term = self.log[-1].term if self.log else 0
        my_last_index = len(self.log) - 1 if self.log else -1

        log_ok = (last_log_term > my_last_term or
                  (last_log_term == my_last_term and
                   last_log_index >= my_last_index))

        vote_granted = (
            (self.voted_for is None or self.voted_for == candidate_id)
            and log_ok
        )

        if vote_granted:
            self.voted_for = candidate_id

        return {"term": self.current_term, "vote_granted": vote_granted}

    def append_entry(self, command: str) -> LogEntry:
        """Leader appends a new entry to its log."""
        entry = LogEntry(
            term=self.current_term,
            index=len(self.log),
            command=command,
        )
        self.log.append(entry)
        return entry
```

### Paxos vs Raft vs PBFT Comparison

| Algorithm | Fault Model | Tolerance | Rounds | Complexity |
|-----------|-------------|-----------|--------|------------|
| Paxos | Crash faults | f < n/2 | 2 (normal) | Difficult to implement correctly |
| Raft | Crash faults | f < n/2 | 2 (normal) | Designed for understandability |
| PBFT | Byzantine faults | f < n/3 | 3 | O(n^2) message complexity |
| HotStuff | Byzantine faults | f < n/3 | 3 | O(n) with pipelining |

## Replication Strategies

### State Machine Replication

```python
class ReplicatedStateMachine:
    """
    State machine replication with configurable consistency.
    Demonstrates read/write quorum intersection for correctness.
    """

    def __init__(self, n_replicas: int, read_quorum: int = None,
                 write_quorum: int = None):
        self.n = n_replicas
        self.R = read_quorum or (n_replicas // 2 + 1)
        self.W = write_quorum or (n_replicas // 2 + 1)

        # Quorum intersection guarantees: R + W > N
        assert self.R + self.W > self.n, (
            f"Quorum intersection violated: R({self.R}) + W({self.W}) "
            f"must be > N({self.n})"
        )

        self.replicas = [{} for _ in range(n_replicas)]
        self.version_clock = 0

    def write(self, key: str, value: str) -> dict:
        """Write to W replicas."""
        self.version_clock += 1
        # Select W replicas (in practice, based on availability)
        targets = random.sample(range(self.n), self.W)
        for i in targets:
            self.replicas[i][key] = (value, self.version_clock)

        return {
            "key": key,
            "version": self.version_clock,
            "acked_by": len(targets),
            "quorum_met": True,
        }

    def read(self, key: str) -> dict:
        """Read from R replicas, return latest version."""
        targets = random.sample(range(self.n), self.R)
        responses = []
        for i in targets:
            if key in self.replicas[i]:
                responses.append(self.replicas[i][key])

        if not responses:
            return {"key": key, "value": None, "found": False}

        # Return the value with the highest version
        latest = max(responses, key=lambda x: x[1])
        return {
            "key": key,
            "value": latest[0],
            "version": latest[1],
            "found": True,
        }
```

## Clock Synchronization and Ordering

### Vector Clocks

```python
class VectorClock:
    """Vector clock for tracking causality in distributed systems."""

    def __init__(self, process_id: str, processes: list[str]):
        self.pid = process_id
        self.clock = {p: 0 for p in processes}

    def increment(self):
        """Local event: increment own counter."""
        self.clock[self.pid] += 1

    def send(self) -> dict:
        """Prepare clock for sending with a message."""
        self.increment()
        return dict(self.clock)

    def receive(self, other_clock: dict):
        """Merge received clock: element-wise max, then increment."""
        for p in self.clock:
            self.clock[p] = max(self.clock[p], other_clock.get(p, 0))
        self.increment()

    def happened_before(self, other: dict) -> bool:
        """Check if this clock happened-before other (causal ordering)."""
        return (all(self.clock[p] <= other.get(p, 0) for p in self.clock) and
                any(self.clock[p] < other.get(p, 0) for p in self.clock))
```

## Performance Analysis

### Latency and Throughput Modeling

Key metrics for evaluating distributed systems:

- **Tail latency (p99, p999)**: Critical for real-world SLAs; often dominated by slow replicas
- **Throughput under contention**: How performance degrades with conflict rate
- **Scalability**: Linear vs sub-linear throughput increase with added nodes
- **Recovery time**: Time to restore consistency after node failure

## Key Research Papers

- Lamport, L. (1998). The Part-Time Parliament (Paxos). *ACM TOCS*.
- Ongaro, D. and Ousterhout, J. (2014). In Search of an Understandable Consensus Algorithm (Raft). *USENIX ATC*.
- Corbett, J. et al. (2013). Spanner: Google's Globally-Distributed Database. *ACM TOCS*.
- DeCandia, G. et al. (2007). Dynamo: Amazon's Highly Available Key-value Store. *SOSP*.

## Tools and Frameworks

- **etcd / ZooKeeper**: Production consensus stores for coordination
- **Jepsen**: Distributed systems correctness testing framework
- **TLA+ / PlusCal**: Formal specification and model checking
- **ns-3 / OMNeT++**: Network simulation for distributed protocols
- **gRPC / Cap'n Proto**: High-performance RPC frameworks
- **FoundationDB**: Multi-model distributed database with strong consistency
