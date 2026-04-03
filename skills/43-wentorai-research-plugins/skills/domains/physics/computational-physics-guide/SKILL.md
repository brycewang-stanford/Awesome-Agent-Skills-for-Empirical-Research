---
name: computational-physics-guide
description: "Computational physics methods, simulations, and research tools"
metadata:
  openclaw:
    emoji: "⚛️"
    category: "domains"
    subcategory: "physics"
    keywords: ["computational physics", "quantum mechanics", "statistical physics", "condensed matter"]
    source: "wentor-research-plugins"
---

# Computational Physics Guide

Apply computational methods to physics research, including molecular dynamics, Monte Carlo simulations, quantum computing, and numerical methods for solving physical systems.

## Computational Methods Overview

| Method | Application | Scale | Key Software |
|--------|-------------|-------|-------------|
| **Molecular Dynamics (MD)** | Atomic-scale dynamics, materials | Atoms-molecules | LAMMPS, GROMACS, NAMD |
| **Density Functional Theory (DFT)** | Electronic structure, quantum chemistry | Electrons | VASP, Gaussian, Quantum ESPRESSO |
| **Monte Carlo (MC)** | Statistical mechanics, phase transitions | Configurable | Custom, CASINO |
| **Finite Element Method (FEM)** | Continuum mechanics, electrostatics | Macroscopic | COMSOL, FEniCS, Abaqus |
| **Finite Difference (FDTD)** | Electrodynamics, wave propagation | Macroscopic | Meep, Lumerical |
| **N-body Simulation** | Gravitational dynamics, plasma | Stars/particles | GADGET, REBOUND |
| **Lattice QCD** | Quantum chromodynamics | Subatomic | MILC, openQCD |

## Molecular Dynamics

### Basic MD Algorithm

```python
import numpy as np

def lennard_jones(r, epsilon=1.0, sigma=1.0):
    """Lennard-Jones potential and force."""
    r6 = (sigma / r) ** 6
    r12 = r6 ** 2
    potential = 4 * epsilon * (r12 - r6)
    force = 24 * epsilon * (2 * r12 - r6) / r
    return potential, force

def velocity_verlet(positions, velocities, forces, masses, dt):
    """Velocity Verlet integration step."""
    # Half-step velocity update
    velocities += 0.5 * forces / masses * dt
    # Full-step position update
    positions += velocities * dt
    # Compute new forces
    new_forces = compute_forces(positions)
    # Complete velocity update
    velocities += 0.5 * new_forces / masses * dt
    return positions, velocities, new_forces

def md_simulation(n_atoms, n_steps, dt=0.001, temperature=1.0):
    """Simple NVE molecular dynamics simulation."""
    # Initialize positions on a grid
    positions = initialize_fcc_lattice(n_atoms, box_size=10.0)
    velocities = np.random.randn(n_atoms, 3) * np.sqrt(temperature)
    velocities -= velocities.mean(axis=0)  # Remove center of mass motion

    forces = compute_forces(positions)
    trajectory = []

    for step in range(n_steps):
        positions, velocities, forces = velocity_verlet(
            positions, velocities, forces,
            masses=np.ones(n_atoms), dt=dt
        )
        if step % 100 == 0:
            ke = 0.5 * np.sum(velocities**2)
            pe = compute_potential_energy(positions)
            print(f"Step {step}: KE={ke:.4f}, PE={pe:.4f}, Total={ke+pe:.4f}")
            trajectory.append(positions.copy())

    return trajectory
```

### LAMMPS Input Script Example

```
# LAMMPS input: Lennard-Jones fluid simulation
units           lj
atom_style      atomic
boundary        p p p

# Create simulation box and atoms
lattice         fcc 0.8442
region          box block 0 10 0 10 0 10
create_box      1 box
create_atoms    1 box

# Set mass and interactions
mass            1 1.0
pair_style      lj/cut 2.5
pair_coeff      1 1 1.0 1.0 2.5

# Initialize velocities at T=1.0
velocity        all create 1.0 87287 dist gaussian

# Thermostat: Nose-Hoover NVT
fix             1 all nvt temp 1.0 1.0 0.1

# Output settings
thermo          100
thermo_style    custom step temp pe ke etotal press
dump            1 all custom 1000 trajectory.lammpstrj id x y z vx vy vz

# Run simulation
timestep        0.005
run             100000
```

## Monte Carlo Methods

### Metropolis Algorithm for Ising Model

```python
import numpy as np

def ising_monte_carlo(L, temperature, n_steps):
    """2D Ising model simulation using Metropolis algorithm."""
    # Initialize random spin configuration
    spins = np.random.choice([-1, 1], size=(L, L))
    beta = 1.0 / temperature

    energies = []
    magnetizations = []

    for step in range(n_steps):
        for _ in range(L * L):  # One sweep = L^2 single spin flips
            # Choose random spin
            i, j = np.random.randint(0, L, size=2)

            # Calculate energy change for flipping spin (i,j)
            neighbors = (
                spins[(i+1)%L, j] + spins[(i-1)%L, j] +
                spins[i, (j+1)%L] + spins[i, (j-1)%L]
            )
            delta_E = 2 * spins[i, j] * neighbors

            # Metropolis acceptance criterion
            if delta_E <= 0 or np.random.random() < np.exp(-beta * delta_E):
                spins[i, j] *= -1

        # Measure observables
        if step % 10 == 0:
            E = -np.sum(spins * (np.roll(spins, 1, 0) + np.roll(spins, 1, 1)))
            M = np.abs(np.sum(spins))
            energies.append(E / L**2)
            magnetizations.append(M / L**2)

    return energies, magnetizations

# Run near the critical temperature (T_c ≈ 2.269 for 2D Ising)
E, M = ising_monte_carlo(L=32, temperature=2.269, n_steps=10000)
print(f"Mean energy: {np.mean(E[-100:]):.4f}")
print(f"Mean magnetization: {np.mean(M[-100:]):.4f}")
```

## Density Functional Theory

### Quantum ESPRESSO Workflow

```bash
# Step 1: Self-consistent field (SCF) calculation
cat > si_scf.in << 'EOF'
&CONTROL
  calculation = 'scf'
  prefix = 'silicon'
  outdir = './tmp/'
  pseudo_dir = './pseudo/'
/
&SYSTEM
  ibrav = 2
  celldm(1) = 10.26  ! Lattice constant in Bohr
  nat = 2
  ntyp = 1
  ecutwfc = 30.0     ! Kinetic energy cutoff (Ry)
  ecutrho = 300.0    ! Charge density cutoff (Ry)
/
&ELECTRONS
  conv_thr = 1.0d-8
/
ATOMIC_SPECIES
  Si 28.086 Si.pbe-n-rrkjus_psl.1.0.0.UPF
ATOMIC_POSITIONS crystal
  Si 0.00 0.00 0.00
  Si 0.25 0.25 0.25
K_POINTS automatic
  8 8 8 0 0 0
EOF

pw.x < si_scf.in > si_scf.out

# Step 2: Band structure calculation
# (requires nscf + bands post-processing)
```

### Python Interface (ASE + GPAW)

```python
from ase.build import bulk
from gpaw import GPAW, PW

# Create silicon crystal structure
si = bulk('Si', 'diamond', a=5.43)

# DFT calculation with GPAW
calc = GPAW(mode=PW(300),       # Plane-wave cutoff: 300 eV
            kpts=(8, 8, 8),      # k-point mesh
            xc='PBE',            # Exchange-correlation functional
            txt='si_gpaw.txt')   # Output file

si.calc = calc
energy = si.get_potential_energy()
print(f"Total energy: {energy:.4f} eV")
print(f"Energy per atom: {energy/len(si):.4f} eV")

# Equation of state (find equilibrium lattice constant)
from ase.eos import EquationOfState
volumes, energies = [], []
for a in np.linspace(5.3, 5.6, 10):
    si = bulk('Si', 'diamond', a=a)
    si.calc = GPAW(mode=PW(300), kpts=(8,8,8), xc='PBE', txt=None)
    volumes.append(si.get_volume())
    energies.append(si.get_potential_energy())

eos = EquationOfState(volumes, energies)
v0, e0, B = eos.fit()
print(f"Equilibrium volume: {v0:.2f} A^3, Bulk modulus: {B:.1f} GPa")
```

## Numerical Methods

### Solving ODEs (Runge-Kutta)

```python
from scipy.integrate import solve_ivp
import matplotlib.pyplot as plt

# Example: Damped harmonic oscillator
# m*x'' + gamma*x' + k*x = 0
def damped_oscillator(t, y, gamma=0.1, omega0=1.0):
    x, v = y
    dxdt = v
    dvdt = -2*gamma*v - omega0**2 * x
    return [dxdt, dvdt]

sol = solve_ivp(damped_oscillator, [0, 50], [1.0, 0.0],
                t_eval=np.linspace(0, 50, 1000),
                method='RK45', rtol=1e-10)

plt.plot(sol.t, sol.y[0])
plt.xlabel('Time')
plt.ylabel('Displacement')
plt.title('Damped Harmonic Oscillator')
plt.savefig('oscillator.pdf', dpi=300)
```

### Solving PDEs (Finite Differences)

```python
# 2D Heat equation: du/dt = alpha * (d2u/dx2 + d2u/dy2)
def heat_equation_2d(Nx, Ny, Nt, alpha=0.01, dt=0.001):
    dx = dy = 1.0 / max(Nx, Ny)
    u = np.zeros((Nx, Ny))
    u[Nx//4:3*Nx//4, Ny//4:3*Ny//4] = 1.0  # Initial hot region

    for t in range(Nt):
        u_new = u.copy()
        u_new[1:-1, 1:-1] = u[1:-1, 1:-1] + alpha * dt / dx**2 * (
            u[2:, 1:-1] + u[:-2, 1:-1] + u[1:-1, 2:] + u[1:-1, :-2]
            - 4 * u[1:-1, 1:-1]
        )
        u = u_new
    return u
```

## HPC and Parallelization

| Approach | Tool | Best For |
|----------|------|----------|
| Shared memory (threads) | OpenMP | Multi-core CPU parallelism |
| Distributed memory (MPI) | mpi4py, MPI | Multi-node cluster computing |
| GPU computing | CUDA, CuPy, JAX | Massively parallel computations |
| Workflow management | Snakemake, Nextflow | Complex simulation pipelines |
| Job scheduling | SLURM, PBS | HPC cluster job submission |

## Research Resources

| Resource | Description |
|----------|-------------|
| arXiv cond-mat | Condensed matter preprints |
| arXiv hep-lat | Lattice field theory preprints |
| Journal of Computational Physics | Top computational physics journal |
| Physical Review E | Statistical, nonlinear, soft matter |
| Computer Physics Communications | Methods + software papers |
| NIST databases | Physical constants, atomic data |
