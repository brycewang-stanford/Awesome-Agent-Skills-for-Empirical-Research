# Venue Map

Use this file to decide where to search first for Industrial AI topics.

## Primary Anchors

Use these first unless the prompt clearly points elsewhere.

| Bucket | Why it is primary | Typical use |
|---|---|---|
| arXiv `eess.SY` | Fast-moving systems and control adjacent work | industrial intelligence, scheduling, optimization, CPS |
| arXiv `cs.AI` | Rapid publication of AI methods and planning work | anomaly detection, scheduling intelligence, decision support |
| IEEE Transactions on Automation Science and Engineering (T-ASE) | Strong automation and industrial systems venue | manufacturing, scheduling, industrial optimization, human-in-the-loop automation |
| IEEE CASE | Core automation conference for applied automation systems | planning, scheduling, logistics, digital factory, industrial AI systems |

## Secondary Crossover Venues

Use these when the prompt crosses into robotics, embodied decision-making, or learning-heavy methods.

| Venue | Use when |
|---|---|
| ICRA | robotics-heavy industrial automation, manipulation, embodied systems |
| IROS | robotics systems, mobile automation, sensing and deployment |
| IEEE RA-L | fast robotics publication, often paired with conference results |
| IEEE Transactions on Robotics (T-RO) | mature robotics methods with industrial crossover |
| arXiv `cs.RO` | industrial robotics, mobile robots, manipulation, embodied agents |
| arXiv `cs.LG` | method-heavy learning papers that influence industrial AI workflows |

## Adjacent Secondary Venues

Use these only after the primary anchors are covered.

| Venue | Typical value |
|---|---|
| IEEE Transactions on Industrial Informatics | industrial sensing, diagnostics, cyber-physical intelligence |
| IEEE Transactions on Industrial Electronics | control and industrial implementation depth |
| IEEE/ASME Transactions on Mechatronics | integrated sensing, control, and actuation systems |
| Automatica | control-theoretic depth and industrial systems rigor |
| IEEE Systems, Man, and Cybernetics: Systems | system-level industrial decision and control topics |

## Subdomain Mapping

| User topic | Start here | Add if needed |
|---|---|---|
| predictive maintenance | T-ASE, T-II, `eess.SY`, `cs.AI` | Automatica, T-IE |
| intelligent scheduling | CASE, T-ASE, `eess.SY`, `cs.AI` | SMC Systems, `cs.LG` |
| industrial anomaly detection | T-II, T-ASE, `cs.AI`, `eess.SY` | `cs.LG`, T-IE |
| smart manufacturing optimization | T-ASE, CASE, Automatica | T-IE, SMC Systems |
| industrial robotics | ICRA, IROS, RA-L, T-RO, `cs.RO` | T-ASE, `cs.LG` |

## Weighting Rule

When multiple venues appear relevant:

1. Prefer Industrial AI and automation venues over general AI venues.
2. Prefer official venue or publisher pages over tertiary summaries.
3. Keep preprints when they are recent and relevant, but label them clearly as preprints.
4. Do not let robotics crossover venues dominate unless the user prompt is robotics-heavy.
