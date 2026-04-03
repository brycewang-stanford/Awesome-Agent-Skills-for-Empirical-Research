---
name: drug-target-interaction
description: "Computational drug-target interaction prediction and virtual screening"
metadata:
  openclaw:
    emoji: "💊"
    category: "domains"
    subcategory: "pharma"
    keywords: ["drug-target", "virtual-screening", "molecular-docking", "binding-affinity", "cheminformatics"]
    source: "wentor"
---

# Drug-Target Interaction Prediction

A skill for computational prediction of drug-target interactions (DTI), covering molecular docking, machine learning-based binding affinity prediction, compound library screening, and target identification using cheminformatics and structural biology tools.

## Drug-Target Interaction Databases

### Key Data Resources

| Database | Content | Access |
|----------|---------|--------|
| ChEMBL | 2.4M compounds, 15M bioactivities | REST API, SQL dump |
| BindingDB | 2.8M binding data points | Bulk download, REST API |
| DrugBank | 15,000+ drug entries with targets | Academic license |
| PDB (Protein Data Bank) | 220,000+ 3D structures | Free download, REST API |
| UniProt | 250M+ protein sequences | Free, REST API |
| STITCH | Chemical-protein interactions | Free academic access |

### Fetching Bioactivity Data

```python
from chembl_webresource_client.new_client import new_client

def get_target_bioactivities(target_chembl_id: str,
                              activity_type: str = "IC50",
                              max_nm: float = 10000) -> list[dict]:
    """
    Retrieve bioactivity data for a protein target from ChEMBL.
    Returns compounds with measured binding/inhibition values.
    """
    activity = new_client.activity
    results = activity.filter(
        target_chembl_id=target_chembl_id,
        standard_type=activity_type,
        standard_relation="=",
        standard_units="nM",
    ).only([
        "molecule_chembl_id", "canonical_smiles",
        "standard_value", "standard_type",
        "pchembl_value", "assay_description",
    ])

    filtered = []
    for r in results:
        if r.get("standard_value") and float(r["standard_value"]) <= max_nm:
            filtered.append({
                "molecule_id": r["molecule_chembl_id"],
                "smiles": r["canonical_smiles"],
                "activity_type": r["standard_type"],
                "value_nM": float(r["standard_value"]),
                "pchembl": float(r["pchembl_value"]) if r.get("pchembl_value") else None,
            })
    return filtered
```

## Molecular Fingerprints and Descriptors

### Computing Molecular Representations

```python
from rdkit import Chem
from rdkit.Chem import AllChem, Descriptors, rdMolDescriptors
import numpy as np

def compute_fingerprints(smiles_list: list[str],
                          fp_type: str = "morgan",
                          radius: int = 2,
                          n_bits: int = 2048) -> np.ndarray:
    """
    Compute molecular fingerprints from SMILES strings.
    fp_type: 'morgan' (ECFP-like), 'maccs', 'rdkit', 'topological'
    """
    fps = []
    for smi in smiles_list:
        mol = Chem.MolFromSmiles(smi)
        if mol is None:
            fps.append(np.zeros(n_bits))
            continue

        if fp_type == "morgan":
            fp = AllChem.GetMorganFingerprintAsBitVect(mol, radius, nBits=n_bits)
        elif fp_type == "maccs":
            fp = rdMolDescriptors.GetMACCSKeysFingerprint(mol)
        elif fp_type == "rdkit":
            fp = Chem.RDKFingerprint(mol, fpSize=n_bits)
        else:
            fp = AllChem.GetMorganFingerprintAsBitVect(mol, radius, nBits=n_bits)

        arr = np.zeros(len(fp))
        Chem.DataStructs.ConvertToNumpyArray(fp, arr)
        fps.append(arr)

    return np.array(fps)

def compute_descriptors(smiles: str) -> dict:
    """Compute physicochemical descriptors for a molecule."""
    mol = Chem.MolFromSmiles(smiles)
    if mol is None:
        return {}
    return {
        "molecular_weight": Descriptors.MolWt(mol),
        "logP": Descriptors.MolLogP(mol),
        "hbd": Descriptors.NumHDonors(mol),
        "hba": Descriptors.NumHAcceptors(mol),
        "tpsa": Descriptors.TPSA(mol),
        "rotatable_bonds": Descriptors.NumRotatableBonds(mol),
        "aromatic_rings": Descriptors.NumAromaticRings(mol),
        "lipinski_violations": sum([
            Descriptors.MolWt(mol) > 500,
            Descriptors.MolLogP(mol) > 5,
            Descriptors.NumHDonors(mol) > 5,
            Descriptors.NumHAcceptors(mol) > 10,
        ]),
    }
```

## Machine Learning for DTI Prediction

### Binary Classification Model

```python
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import StratifiedKFold
from sklearn.metrics import roc_auc_score, average_precision_score

def train_dti_classifier(compound_fps: np.ndarray,
                          target_features: np.ndarray,
                          labels: np.ndarray) -> dict:
    """
    Train a DTI classifier using compound-target pair features.
    compound_fps: molecular fingerprints (n_samples, fp_dim)
    target_features: protein descriptors (n_samples, target_dim)
    labels: binary interaction labels (1=interacts, 0=no interaction)
    """
    # Concatenate compound and target features
    X = np.hstack([compound_fps, target_features])
    y = labels

    skf = StratifiedKFold(n_splits=5, shuffle=True, random_state=42)
    metrics = {"auroc": [], "auprc": []}

    for train_idx, test_idx in skf.split(X, y):
        model = RandomForestClassifier(
            n_estimators=500, max_depth=20, n_jobs=-1, random_state=42
        )
        model.fit(X[train_idx], y[train_idx])
        pred_proba = model.predict_proba(X[test_idx])[:, 1]

        metrics["auroc"].append(roc_auc_score(y[test_idx], pred_proba))
        metrics["auprc"].append(average_precision_score(y[test_idx], pred_proba))

    return {
        "mean_auroc": np.mean(metrics["auroc"]),
        "mean_auprc": np.mean(metrics["auprc"]),
        "model": model,
    }
```

### Deep Learning Approaches

Modern DTI prediction architectures:

| Method | Compound Representation | Target Representation | Architecture |
|--------|------------------------|----------------------|-------------|
| DeepDTA | SMILES (1D CNN) | Protein sequence (1D CNN) | Concatenation + FC |
| GraphDTA | Molecular graph (GCN/GAT) | Protein sequence (CNN) | Graph + sequence fusion |
| MolTrans | SMILES (Transformer) | Protein sequence (Transformer) | Cross-attention |
| DrugBAN | Molecular graph | Protein graph | Bilinear attention |

## Molecular Docking

### Structure-Based Virtual Screening

```python
import subprocess

def run_autodock_vina(receptor_pdbqt: str, ligand_pdbqt: str,
                      center: tuple, box_size: tuple = (20, 20, 20),
                      exhaustiveness: int = 8) -> dict:
    """
    Run AutoDock Vina for molecular docking.
    receptor_pdbqt: path to prepared receptor file
    ligand_pdbqt: path to prepared ligand file
    center: (x, y, z) coordinates of the binding site center
    Returns docking scores and poses.
    """
    cmd = [
        "vina",
        "--receptor", receptor_pdbqt,
        "--ligand", ligand_pdbqt,
        "--center_x", str(center[0]),
        "--center_y", str(center[1]),
        "--center_z", str(center[2]),
        "--size_x", str(box_size[0]),
        "--size_y", str(box_size[1]),
        "--size_z", str(box_size[2]),
        "--exhaustiveness", str(exhaustiveness),
        "--num_modes", "9",
    ]
    result = subprocess.run(cmd, capture_output=True, text=True)
    # Parse output for binding affinities
    scores = []
    for line in result.stdout.split("\n"):
        parts = line.split()
        if len(parts) >= 4 and parts[0].isdigit():
            scores.append({
                "mode": int(parts[0]),
                "affinity_kcal_mol": float(parts[1]),
                "rmsd_lb": float(parts[2]),
                "rmsd_ub": float(parts[3]),
            })
    return {"scores": scores, "best_affinity": scores[0]["affinity_kcal_mol"] if scores else None}
```

## Validation and Benchmarking

Standard benchmarks for DTI prediction:

- **DUD-E**: Directory of Useful Decoys, Enhanced (102 targets, 22,886 actives)
- **MUV**: Maximum Unbiased Validation datasets (17 targets)
- **LIT-PCBA**: Large-scale confirmatory bioassay benchmark
- **Davis and KIBA**: Kinase binding affinity datasets for regression

## Tools and Libraries

- **RDKit**: Open-source cheminformatics toolkit
- **AutoDock Vina / Smina**: Molecular docking engines
- **OpenMM**: GPU-accelerated molecular dynamics
- **DeepChem**: Deep learning for drug discovery
- **PyMOL / ChimeraX**: Molecular visualization
- **Open Babel**: Chemical file format conversion
