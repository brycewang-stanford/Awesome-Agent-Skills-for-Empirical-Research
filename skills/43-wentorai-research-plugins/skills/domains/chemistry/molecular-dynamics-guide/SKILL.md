---
name: molecular-dynamics-guide
description: "Molecular dynamics simulation setup, execution, and trajectory analysis"
metadata:
  openclaw:
    emoji: "⚛️"
    category: "domains"
    subcategory: "chemistry"
    keywords: ["molecular-dynamics", "simulation", "gromacs", "openmm", "force-field", "trajectory"]
    source: "wentor"
---

# Molecular Dynamics Guide

A skill for setting up, running, and analyzing molecular dynamics (MD) simulations. Covers force field selection, system preparation, simulation protocols, trajectory analysis, and free energy calculations using GROMACS, OpenMM, and MDAnalysis.

## System Preparation

### Building a Simulation System

The standard workflow for preparing an MD simulation:

```
1. Obtain structure (PDB, homology model, or docking pose)
2. Clean structure (add missing atoms, fix protonation states)
3. Assign force field parameters
4. Solvate in explicit water box
5. Add counterions to neutralize charge
6. Energy minimize
7. Equilibrate (NVT then NPT)
8. Production run
```

### GROMACS System Setup

```bash
# 1. Generate topology from PDB
gmx pdb2gmx -f protein.pdb -o processed.gro -water tip3p -ff amber99sb-ildn

# 2. Define simulation box (dodecahedron, 1.0 nm buffer)
gmx editconf -f processed.gro -o boxed.gro -c -d 1.0 -bt dodecahedron

# 3. Solvate
gmx solvate -cp boxed.gro -cs spc216.gro -o solvated.gro -p topol.top

# 4. Add ions to neutralize and set ionic strength (0.15 M NaCl)
gmx grompp -f ions.mdp -c solvated.gro -p topol.top -o ions.tpr
gmx genion -s ions.tpr -o ionized.gro -p topol.top -pname NA -nname CL -neutral -conc 0.15

# 5. Energy minimization
gmx grompp -f minim.mdp -c ionized.gro -p topol.top -o em.tpr
gmx mdrun -deffnm em

# 6. NVT equilibration (100 ps, 300 K)
gmx grompp -f nvt.mdp -c em.gro -r em.gro -p topol.top -o nvt.tpr
gmx mdrun -deffnm nvt

# 7. NPT equilibration (100 ps, 300 K, 1 bar)
gmx grompp -f npt.mdp -c nvt.gro -r nvt.gro -t nvt.cpt -p topol.top -o npt.tpr
gmx mdrun -deffnm npt

# 8. Production MD (100 ns)
gmx grompp -f md.mdp -c npt.gro -t npt.cpt -p topol.top -o md.tpr
gmx mdrun -deffnm md
```

## Force Field Selection

### Common Force Fields

| Force Field | Strengths | Typical Use |
|-------------|-----------|------------|
| AMBER ff14SB | Protein structure, dynamics | Protein simulations |
| AMBER ff19SB | Improved backbone dihedrals | Latest protein simulations |
| CHARMM36m | Proteins, lipids, carbohydrates | Membrane systems |
| OPLS-AA/M | Small molecules, organic liquids | Drug-like molecules |
| GAFF2 | General small molecules | Ligand parameterization |
| CGenFF | CHARMM-compatible small molecules | Ligands in CHARMM systems |

### OpenMM System Setup

```python
from openmm.app import PDBFile, ForceField, Modeller, Simulation
from openmm.app import PME, HBonds, NoCutoff
from openmm import LangevinMiddleIntegrator, MonteCarloBarostat
from openmm.unit import kelvin, atmospheres, nanometers, picoseconds

def setup_openmm_simulation(pdb_path: str,
                              temperature: float = 300,
                              pressure: float = 1.0,
                              timestep: float = 0.002) -> Simulation:
    """
    Set up an OpenMM molecular dynamics simulation.
    pdb_path: path to prepared PDB file
    temperature: simulation temperature in Kelvin
    pressure: pressure in atmospheres
    timestep: integration timestep in picoseconds
    """
    pdb = PDBFile(pdb_path)
    forcefield = ForceField("amber14-all.xml", "amber14/tip3pfb.xml")

    modeller = Modeller(pdb.topology, pdb.positions)
    modeller.addSolvent(forcefield, padding=1.0 * nanometers,
                        ionicStrength=0.15)

    system = forcefield.createSystem(
        modeller.topology,
        nonbondedMethod=PME,
        nonbondedCutoff=1.0 * nanometers,
        constraints=HBonds,
    )

    # Barostat for NPT ensemble
    system.addForce(
        MonteCarloBarostat(pressure * atmospheres, temperature * kelvin)
    )

    integrator = LangevinMiddleIntegrator(
        temperature * kelvin,
        1.0 / picoseconds,
        timestep * picoseconds,
    )

    simulation = Simulation(modeller.topology, system, integrator)
    simulation.context.setPositions(modeller.positions)

    # Energy minimization
    simulation.minimizeEnergy()

    return simulation
```

## Trajectory Analysis

### Structural Analysis with MDAnalysis

```python
import MDAnalysis as mda
from MDAnalysis.analysis import rms, align, diffusionmap
import numpy as np

def analyze_trajectory(topology: str, trajectory: str) -> dict:
    """
    Comprehensive trajectory analysis: RMSD, RMSF, radius of gyration.
    topology: topology file (GRO, PDB, PSF)
    trajectory: trajectory file (XTC, TRR, DCD)
    """
    u = mda.Universe(topology, trajectory)
    protein = u.select_atoms("protein and name CA")

    # RMSD over time (C-alpha atoms)
    ref = mda.Universe(topology)
    rmsd_analysis = rms.RMSD(u, ref, select="protein and name CA")
    rmsd_analysis.run()
    rmsd_data = rmsd_analysis.results.rmsd  # shape: (n_frames, 3)

    # RMSF per residue
    align.AlignTraj(u, ref, select="protein and name CA", in_memory=True).run()
    rmsf = rms.RMSF(protein).run()

    # Radius of gyration
    rg_values = []
    for ts in u.trajectory:
        rg_values.append(protein.radius_of_gyration())

    return {
        "n_frames": len(u.trajectory),
        "rmsd_mean_nm": np.mean(rmsd_data[:, 2]) / 10,  # A to nm
        "rmsd_final_nm": rmsd_data[-1, 2] / 10,
        "rmsf_mean_nm": np.mean(rmsf.results.rmsf) / 10,
        "rg_mean_nm": np.mean(rg_values) / 10,
        "rg_std_nm": np.std(rg_values) / 10,
        "simulation_time_ns": u.trajectory[-1].time / 1000,
    }
```

### Hydrogen Bond Analysis

```python
from MDAnalysis.analysis.hydrogenbonds import HydrogenBondAnalysis

def analyze_hbonds(universe: mda.Universe,
                    donor_sel: str = "protein",
                    acceptor_sel: str = "protein") -> dict:
    """Analyze hydrogen bonds over the trajectory."""
    hbonds = HydrogenBondAnalysis(
        universe,
        donors_sel=f"({donor_sel}) and (name N* or name O*)",
        acceptors_sel=f"({acceptor_sel}) and (name O* or name N*)",
        d_a_cutoff=3.5,
        d_h_a_angle_cutoff=150,
    )
    hbonds.run()

    return {
        "total_hbonds_detected": len(hbonds.results.hbonds),
        "mean_per_frame": len(hbonds.results.hbonds) / hbonds.n_frames,
        "unique_pairs": len(set(
            (int(r[1]), int(r[3])) for r in hbonds.results.hbonds
        )),
    }
```

## Free Energy Methods

### Umbrella Sampling

Umbrella sampling computes the potential of mean force (PMF) along a reaction coordinate:

1. Generate windows along the reaction coordinate (e.g., distance between two groups)
2. Run restrained simulations at each window with a harmonic bias
3. Combine windows using WHAM (Weighted Histogram Analysis Method)
4. Report the free energy profile (PMF)

### Alchemical Free Energy Perturbation

Used for computing binding free energies and solvation free energies:

```
Lambda schedule: 0.0, 0.1, 0.2, ..., 0.9, 1.0
At lambda=0: full interaction (bound state)
At lambda=1: no interaction (unbound state)

Each lambda window: independent MD simulation
Analysis: MBAR or TI to combine lambda windows
```

## Tools and Software

- **GROMACS**: High-performance MD engine (free, GPU-accelerated)
- **OpenMM**: Python-native MD with GPU support
- **AMBER**: Comprehensive MD package (academic license)
- **NAMD**: Scalable MD for large biomolecular systems
- **MDAnalysis**: Python trajectory analysis library
- **MDTraj**: Lightweight trajectory analysis
- **PyMOL / VMD**: Molecular visualization and movie generation
- **PLUMED**: Free energy and enhanced sampling methods plugin
