---
name: quantum-computing-guide
description: "Explore quantum computing research with Qiskit and Cirq frameworks"
metadata:
  openclaw:
    emoji: "⚛️"
    category: "domains"
    subcategory: "physics"
    keywords: ["quantum computing", "Qiskit", "Cirq", "quantum circuits", "qubit", "quantum algorithms"]
    source: "wentor-research-plugins"
---

# Quantum Computing Guide

A skill for conducting quantum computing research using Qiskit (IBM) and Cirq (Google) frameworks. Covers quantum circuit construction, fundamental algorithms, noise simulation, and practical considerations for running experiments on quantum hardware.

## Quantum Computing Fundamentals

### Key Concepts

```
Qubit: The basic unit of quantum information
  - Superposition: A qubit can be in a state |0>, |1>, or any
    linear combination alpha|0> + beta|1> where |alpha|^2 + |beta|^2 = 1
  - Measurement: Collapses to |0> with probability |alpha|^2
    or |1> with probability |beta|^2

Entanglement: Two qubits can be correlated in ways impossible classically
  - Bell state: (|00> + |11>) / sqrt(2)
  - Measuring one qubit instantly determines the other

Quantum gates: Unitary operations that transform qubit states
  - Single-qubit: H (Hadamard), X (NOT), Z, S, T, Rx, Ry, Rz
  - Two-qubit: CNOT, CZ, SWAP
  - Multi-qubit: Toffoli (CCNOT), Fredkin (CSWAP)
```

## Building Quantum Circuits with Qiskit

### Basic Circuit Construction

```python
from qiskit import QuantumCircuit
from qiskit_aer import AerSimulator


def create_bell_state() -> QuantumCircuit:
    """
    Create a Bell state (maximally entangled pair).
    """
    qc = QuantumCircuit(2, 2)

    # Apply Hadamard to qubit 0 (creates superposition)
    qc.h(0)

    # Apply CNOT with qubit 0 as control, qubit 1 as target
    qc.cx(0, 1)

    # Measure both qubits
    qc.measure([0, 1], [0, 1])

    return qc


def run_circuit(qc: QuantumCircuit, shots: int = 1024) -> dict:
    """
    Run a quantum circuit on a simulator.

    Args:
        qc: Quantum circuit to execute
        shots: Number of measurement repetitions
    """
    simulator = AerSimulator()
    result = simulator.run(qc, shots=shots).result()
    counts = result.get_counts()

    return {
        "counts": counts,
        "probabilities": {
            state: count / shots for state, count in counts.items()
        }
    }
```

### Quantum Teleportation Circuit

```python
def quantum_teleportation() -> QuantumCircuit:
    """
    Implement quantum teleportation protocol.
    Transfers the state of qubit 0 to qubit 2 using entanglement.
    """
    qc = QuantumCircuit(3, 3)

    # Prepare an arbitrary state on qubit 0
    qc.rx(1.2, 0)
    qc.rz(0.7, 0)

    qc.barrier()

    # Create entangled pair (qubits 1 and 2)
    qc.h(1)
    qc.cx(1, 2)

    qc.barrier()

    # Bell measurement on qubits 0 and 1
    qc.cx(0, 1)
    qc.h(0)
    qc.measure([0, 1], [0, 1])

    qc.barrier()

    # Conditional corrections on qubit 2
    qc.cx(1, 2)
    qc.cz(0, 2)

    qc.measure(2, 2)

    return qc
```

## Fundamental Quantum Algorithms

### Algorithm Overview

| Algorithm | Speedup | Problem |
|-----------|---------|---------|
| Grover's | Quadratic (sqrt(N)) | Unstructured search |
| Shor's | Exponential | Integer factorization |
| VQE | Heuristic | Ground state energy |
| QAOA | Heuristic | Combinatorial optimization |
| Quantum Phase Estimation | Exponential | Eigenvalue estimation |
| HHL | Exponential (conditions apply) | Linear systems |

### Variational Quantum Eigensolver (VQE)

```python
from qiskit.circuit.library import TwoLocal


def build_vqe_circuit(n_qubits: int, depth: int = 2) -> dict:
    """
    Build a parameterized ansatz circuit for VQE.

    Args:
        n_qubits: Number of qubits
        depth: Circuit depth (repetitions)
    """
    ansatz = TwoLocal(
        n_qubits,
        rotation_blocks=["ry", "rz"],
        entanglement_blocks="cx",
        entanglement="linear",
        reps=depth
    )

    return {
        "circuit": ansatz,
        "n_parameters": ansatz.num_parameters,
        "description": (
            "VQE uses a classical optimizer to minimize "
            "<psi(theta)|H|psi(theta)> where psi(theta) is the "
            "parameterized quantum state and H is the Hamiltonian."
        )
    }
```

## Noise and Error Mitigation

### Simulating Realistic Noise

```python
from qiskit_aer.noise import NoiseModel, depolarizing_error


def create_noisy_simulator(error_rate: float = 0.01) -> dict:
    """
    Create a noise model for realistic quantum simulation.

    Args:
        error_rate: Depolarizing error probability per gate
    """
    noise_model = NoiseModel()

    # Single-qubit gate error
    error_1q = depolarizing_error(error_rate, 1)
    noise_model.add_all_qubit_quantum_error(error_1q, ["h", "rx", "ry", "rz"])

    # Two-qubit gate error (typically higher)
    error_2q = depolarizing_error(error_rate * 10, 2)
    noise_model.add_all_qubit_quantum_error(error_2q, ["cx"])

    return {
        "noise_model": noise_model,
        "single_qubit_error": error_rate,
        "two_qubit_error": error_rate * 10,
        "mitigation_strategies": [
            "Zero-Noise Extrapolation (ZNE)",
            "Probabilistic Error Cancellation (PEC)",
            "Measurement error mitigation",
            "Dynamical decoupling",
            "Quantum error correction (surface codes)"
        ]
    }
```

## Running on Real Hardware

### Practical Considerations

```
1. Qubit connectivity:
   Real devices have limited qubit connections (not all-to-all)
   SWAP gates are needed to route operations -> increases circuit depth

2. Gate fidelity:
   Single-qubit gates: ~99.9% fidelity
   Two-qubit gates: ~99-99.5% fidelity
   Limits useful circuit depth to ~100-1000 gates

3. Coherence times:
   T1 (energy relaxation): 100-500 microseconds
   T2 (dephasing): 50-200 microseconds
   Circuit must complete before decoherence

4. Queue times:
   Real quantum computers have job queues (minutes to hours)
   Use simulators for development; reserve hardware for final runs
```

## Publishing Quantum Computing Research

Report the exact device used (name, calibration date), number of qubits and connectivity, gate set and fidelities, transpilation settings, number of shots, error mitigation techniques applied, and comparison with classical simulation where tractable. Provide Qiskit or Cirq code in a public repository for reproducibility.
