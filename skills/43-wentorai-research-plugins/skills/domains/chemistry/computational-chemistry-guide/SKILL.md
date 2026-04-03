---
name: computational-chemistry-guide
description: "DFT, molecular simulation, and reaction prediction tools for chemists"
metadata:
  openclaw:
    emoji: "⚗"
    category: "domains"
    subcategory: "chemistry"
    keywords: ["computational chemistry", "DFT", "quantum chemistry", "reaction prediction"]
    source: "wentor-research-plugins"
---

# Computational Chemistry Guide

## Overview

Computational chemistry bridges quantum mechanics and practical chemistry, enabling researchers to predict molecular properties, reaction mechanisms, and material behaviors without stepping into a wet lab. From drug design to catalyst optimization, computational methods accelerate discovery by screening thousands of candidates before committing to synthesis.

This guide covers the major computational chemistry paradigms: Density Functional Theory (DFT) for electronic structure calculations, molecular dynamics (MD) for simulating atomic motion, machine learning potentials for scaling up simulations, and reaction prediction tools for retrosynthesis and mechanism elucidation. Each section includes tool recommendations, typical workflows, and code examples.

Whether you are a chemistry PhD student running your first Gaussian calculations, a materials scientist exploring new alloys with VASP, or a medicinal chemist using ML-based property prediction, this skill provides the conceptual framework and practical recipes to get productive quickly.

## Density Functional Theory (DFT)

### When to Use DFT

DFT is the workhorse of quantum chemistry. It provides a good balance of accuracy and computational cost for systems of up to a few hundred atoms.

| Property | DFT Suitability | Typical Error |
|----------|----------------|---------------|
| Molecular geometry | Excellent | < 0.02 Angstrom |
| Vibrational frequencies | Good | 3-5% |
| Reaction barriers | Good with correction | 2-5 kcal/mol |
| Band gaps | Fair (tends to underestimate) | 0.5-1.0 eV |
| Van der Waals interactions | Requires dispersion correction | Varies |
| Excited states | Fair (TD-DFT) | 0.2-0.5 eV |

### Software Comparison

| Software | License | Strengths | Basis Sets |
|----------|---------|-----------|-----------|
| Gaussian | Commercial | Broad functionality, well-documented | Gaussian-type |
| ORCA | Free (academic) | DFT + wavefunction methods, excellent support | Gaussian-type |
| VASP | Commercial | Periodic systems, materials science | Plane-wave |
| Quantum ESPRESSO | Open source | Periodic DFT, phonons | Plane-wave |
| Psi4 | Open source | Reference implementations, Python API | Gaussian-type |
| CP2K | Open source | Mixed Gaussian/plane-wave, large systems | Mixed |

### ORCA DFT Workflow Example

```
# geometry_optimization.inp
! B3LYP def2-TZVP D3BJ OPT FREQ
# B3LYP functional, triple-zeta basis, D3 dispersion, optimize + frequencies

%pal
  nprocs 8
end

%maxcore 4000

* xyz 0 1
C  0.000  0.000  0.000
O  1.200  0.000  0.000
H -0.500  0.866  0.000
H -0.500 -0.866  0.000
*
```

Run with:
```bash
orca geometry_optimization.inp > geometry_optimization.out
```

### Analyzing DFT Results with Python

```python
from ase.io import read
from ase.visualize import view

# Read optimized geometry from ORCA output
atoms = read('geometry_optimization.xyz')

# Extract energies from output file
import re

with open('geometry_optimization.out') as f:
    text = f.read()

# Total energy
energy = float(re.search(r'FINAL SINGLE POINT ENERGY\s+([-\d.]+)', text).group(1))
print(f"Total energy: {energy:.6f} Hartree")
print(f"Total energy: {energy * 627.509:.2f} kcal/mol")

# Thermochemistry
gibbs_match = re.search(r'Final Gibbs free energy\s+\.\.\.\s+([-\d.]+)', text)
if gibbs_match:
    gibbs = float(gibbs_match.group(1))
    print(f"Gibbs free energy: {gibbs:.6f} Hartree")
```

## Molecular Dynamics Simulations

### MD Pipeline

```
Initial Structure (.pdb/.mol2)
    |
    v
[Parameterization] --> Force field assignment (AMBER, CHARMM, OPLS)
    |
    v
[Solvation] --> Add solvent box, ions
    |
    v
[Minimization] --> Energy minimization (steepest descent)
    |
    v
[Equilibration] --> NVT then NPT ensemble (100 ps - 1 ns)
    |
    v
[Production] --> NPT ensemble (10 ns - microseconds)
    |
    v
[Analysis] --> RMSD, RMSF, hydrogen bonds, free energy
```

### OpenMM Quick Start

```python
from openmm.app import *
from openmm import *
from openmm.unit import *

# Load structure
pdb = PDBFile('protein.pdb')
forcefield = ForceField('amber14-all.xml', 'amber14/tip3pfb.xml')

# Create system
modeller = Modeller(pdb.topology, pdb.positions)
modeller.addSolvent(forcefield, model='tip3p', padding=1.0*nanometers)

system = forcefield.createSystem(
    modeller.topology,
    nonbondedMethod=PME,
    nonbondedCutoff=1.0*nanometers,
    constraints=HBonds
)

# Set up simulation
integrator = LangevinMiddleIntegrator(300*kelvin, 1/picosecond, 0.004*picoseconds)
simulation = Simulation(modeller.topology, system, integrator)
simulation.context.setPositions(modeller.positions)

# Minimize
simulation.minimizeEnergy()

# Run production (10 ns)
simulation.reporters.append(DCDReporter('trajectory.dcd', 1000))
simulation.reporters.append(
    StateDataReporter('log.csv', 1000, step=True,
                      potentialEnergy=True, temperature=True)
)
simulation.step(2500000)  # 10 ns at 4 fs timestep
```

## Machine Learning in Computational Chemistry

### ML Potential Energy Surfaces

Machine learning potentials achieve near-DFT accuracy at a fraction of the cost:

| Method | Speed vs DFT | Accuracy | Training Data |
|--------|-------------|----------|---------------|
| ANI | 1000x faster | ~1 kcal/mol | Pre-trained |
| SchNet | 100-1000x | ~1 kcal/mol | 1K-100K configs |
| MACE | 100-1000x | < 1 kcal/mol | 1K-100K configs |
| GemNet | 100-1000x | < 1 kcal/mol | 1K-100K configs |

### Property Prediction with RDKit

```python
from rdkit import Chem
from rdkit.Chem import Descriptors, AllChem
import numpy as np

def compute_molecular_features(smiles):
    """Compute molecular descriptors from SMILES string."""
    mol = Chem.MolFromSmiles(smiles)
    if mol is None:
        return None

    features = {
        'molecular_weight': Descriptors.MolWt(mol),
        'logp': Descriptors.MolLogP(mol),
        'hbd': Descriptors.NumHDonors(mol),
        'hba': Descriptors.NumHAcceptors(mol),
        'tpsa': Descriptors.TPSA(mol),
        'rotatable_bonds': Descriptors.NumRotatableBonds(mol),
        'aromatic_rings': Descriptors.NumAromaticRings(mol),
        'heavy_atoms': mol.GetNumHeavyAtoms(),
    }

    # Morgan fingerprint (ECFP4)
    fp = AllChem.GetMorganFingerprintAsBitVect(mol, 2, nBits=2048)
    features['fingerprint'] = np.array(fp)

    return features

# Lipinski's Rule of Five check
def check_druglikeness(smiles):
    feats = compute_molecular_features(smiles)
    if feats is None:
        return False
    return (feats['molecular_weight'] <= 500 and
            feats['logp'] <= 5 and
            feats['hbd'] <= 5 and
            feats['hba'] <= 10)
```

## Reaction Prediction

### Retrosynthesis Tools

| Tool | Approach | Access |
|------|----------|--------|
| ASKCOS | Template-based + ML | MIT, web interface |
| IBM RXN | Transformer-based | Free API |
| Syntheseus | Multi-model framework | Open source |
| RetroTRAE | Transformer | Open source |

### Using RDKit for Reaction Processing

```python
from rdkit.Chem import AllChem, Draw

# Define a reaction (Suzuki coupling)
rxn_smarts = '[c:1][B](O)O.[c:2][Cl]>>[c:1][c:2]'
rxn = AllChem.ReactionFromSmarts(rxn_smarts)

# Apply reaction
reactant1 = Chem.MolFromSmiles('c1ccc(B(O)O)cc1')  # Phenylboronic acid
reactant2 = Chem.MolFromSmiles('c1ccc(Cl)cc1')      # Chlorobenzene

products = rxn.RunReactants((reactant1, reactant2))
for product_set in products:
    for product in product_set:
        print(Chem.MolToSmiles(product))  # Biphenyl
```

## Best Practices

- **Benchmark your method.** Always validate your computational protocol against known experimental data before applying it to new systems.
- **Use appropriate levels of theory.** Do not use MP2 when B3LYP suffices, and do not use B3LYP when you need CCSD(T) accuracy.
- **Include dispersion corrections.** D3BJ or D4 corrections are essential for non-covalent interactions.
- **Check convergence.** Verify that geometry optimizations, SCF calculations, and MD simulations have properly converged.
- **Report computational details completely.** Functional, basis set, dispersion correction, solvent model, and software version should all be stated.
- **Archive your input/output files.** Computational chemistry is reproducible only if all parameters are preserved.

## References

- [ORCA Documentation](https://www.faccts.de/docs/orca/6.0/manual/) -- Free quantum chemistry software
- [OpenMM Documentation](http://docs.openmm.org/) -- GPU-accelerated molecular dynamics
- [RDKit Documentation](https://www.rdkit.org/docs/) -- Cheminformatics toolkit
- [Psi4 Documentation](https://psicode.org/) -- Open-source quantum chemistry
- [A Hitchhiker's Guide to DFT](https://onlinelibrary.wiley.com/doi/book/10.1002/3527600043) -- Koch and Holthausen
