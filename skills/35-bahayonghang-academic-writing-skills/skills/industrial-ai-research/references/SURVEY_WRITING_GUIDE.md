# Survey Writing Guide — Industrial AI

This guide defines the writing philosophy for survey drafts produced by the `survey-draft` deliverable mode. Read this file during all survey phases (S1–S4).

## Why Industrial AI Surveys Are Different

Industrial AI surveys must evaluate work along dimensions that pure ML surveys can ignore:

- **Deployment realism**: algorithm performance alone is insufficient; real-world deployment evidence (pilot lines, factory trials, fleet rollouts) is a first-class evaluation axis.
- **Data scarcity and labeling cost**: most industrial datasets are small, imbalanced, or expensive to annotate. Surveys must surface how each method handles this.
- **Latency spectrum**: acceptable inference latency varies by orders of magnitude (PdM tolerates minutes; scheduling may need sub-second; real-time control needs milliseconds).
- **Sim-to-real gap**: many methods are validated only in simulation. The survey must explicitly flag sim-only vs. real-deployment evidence.
- **Safety and regulatory context**: industrial deployments often intersect with safety standards (IEC 61508, ISO 13849). Note when papers address or ignore these.

## Taxonomy Pattern Library

Use these recommended classification axes when building the survey outline (Phase S1). Combine two axes into a matrix when the literature is dense enough.

| Subdomain | Recommended axes | Example branches |
|-----------|-----------------|-----------------|
| Predictive Maintenance | Signal modality × Method family | Vibration / Acoustic / Current / Multi-modal × CNN / Transformer / Physics-informed / Hybrid |
| Intelligent Scheduling | Problem scale × Solving paradigm | Single-machine / Flexible job-shop / Distributed × Exact / Heuristic / Meta-heuristic / RL |
| Industrial Anomaly Detection | Supervision level × Industrial scenario | Supervised / Semi-supervised / Unsupervised / Self-supervised × Manufacturing / Energy / Process |
| Smart Manufacturing | Production stage × Technology stack | Design / Machining / Assembly / Inspection × Digital twin / Edge AI / Robotics / LLM-assisted |
| CPS and Edge AI | Deployment tier × Optimization target | Cloud / Edge / On-device × Latency / Energy / Accuracy / Privacy |

### Choosing Axes

1. Start with the two axes that produce the most even distribution of papers across cells.
2. If one axis produces a single dominant cell (>50% of papers), consider splitting that axis or switching to a different one.
3. Hybrid taxonomies (e.g., method-based at H2, application-based at H3) are acceptable when a single pair of axes cannot cover the literature.

## Comparison Table Conventions

Comparison tables are mandatory artifacts in survey drafts. Follow these rules:

### Per-H3 Tables (in evidence packs and body sections)

Every H3 subsection must include at least one comparison table with these columns:

| Column | Required | Description |
|--------|----------|-------------|
| Paper | Yes | First author + year |
| Method | Yes | Core technique or model name |
| Dataset | Yes | Benchmark or industrial dataset used |
| Key Metric | Yes | Primary evaluation metric |
| Result | Yes | Quantitative result on key metric |
| Deployment Evidence | Yes | None / Simulation / Pilot / Production |

### Cross-Cutting Table (in Comparative Analysis section)

The Comparative Analysis section (Phase S4) must include at least one cross-cutting table that compares methods across taxonomy branches. Additional columns:

| Column | Required | Description |
|--------|----------|-------------|
| Taxonomy Branch | Yes | Which H2 branch the method belongs to |
| Data Requirement | Recommended | Training data size or labeling need |
| Latency | Recommended | Inference time or real-time capability |
| Scalability | Recommended | Evidence of scaling to production |

## Writing Tone

- Analytical, not promotional. State what the evidence shows, not what "promises" a method holds.
- Use hedging language ("the results suggest", "under the reported conditions") when evidence is limited to a single study.
- Avoid generator-tone phrases: "In this section, we will discuss...", "It is worth noting that...", "Taken together..." (limit to ≤2 occurrences in the entire draft).
- Prefer active constructions: "Zhang et al. [12] propose..." over "A method was proposed by Zhang et al. [12]..."

## Literature Review Quality Standards

Survey papers must exemplify the highest literature review quality. These rules (cross-referenced from the `latex-paper-en` skill's LOGIC module) are especially critical in survey context:

### A1: Thematic Clustering (Mandatory)
Literature MUST be organized by research themes, methodology families, or application domains — never by chronological order or author enumeration. In survey context, the taxonomy axes (see Taxonomy Pattern Library above) define the thematic clusters.

**Anti-pattern**: "In 2018, Smith proposed X. In 2019, Jones introduced Y. In 2020, Wang designed Z."
**Correct pattern**: Group papers by method family (e.g., CNN-based → Transformer-based → Hybrid), then discuss each group's strengths and limitations.

### A2: Critical Analysis After Each Cluster (Mandatory)
Each H3 subsection (theme cluster) MUST end with a critical synthesis paragraph that:
- Summarizes shared strengths and limitations of methods in that cluster
- Identifies open problems within the cluster
- Provides a transition to the next cluster or section

### A3: Research Gap Derivation (Mandatory)
The final subsection of the literature review (or the Comparative Analysis section) MUST explicitly identify:
- Gaps in the current literature that remain unaddressed
- Under-explored combinations of methods and applications
- Missing evaluation dimensions (e.g., deployment evidence, latency, data efficiency)

### A4: Citation Density Funnel
Survey papers naturally follow a funnel pattern: broad introduction citations → focused per-cluster citations → specific technique deep-dives. Maintain this pattern within each H2 section.

> **Full reference**: See `../latex-paper-en/references/modules/LOGIC.md` for detailed detection heuristics and automated check patterns.

## Length Tiers

| Tier | Word range | Typical H2 sections | Typical H3 per H2 |
|------|-----------|---------------------|-------------------|
| Short | 3 000–5 000 | 3–4 | 2–3 |
| Standard | 5 000–10 000 | 4–6 | 3–5 |
| Comprehensive | 10 000–15 000 | 5–7 | 4–6 |
