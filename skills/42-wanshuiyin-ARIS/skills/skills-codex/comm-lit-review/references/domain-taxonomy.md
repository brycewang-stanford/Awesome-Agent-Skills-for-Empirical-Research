# Communications Domain Taxonomy

Use this file to decide whether the request should trigger this skill and how to organize the review.

## Typical trigger topics

- Wireless communications
- Cellular systems, `4G/5G/6G`, `NR`, `NTN`
- Satellite, `LEO`, `GEO`, integrated space-air-ground networks
- Wi-Fi, WLAN, mesh, ad hoc, sidelink, V2X
- Routing, scheduling, resource allocation, beamforming
- Rate adaptation, link adaptation, ACM, HARQ, CSI feedback
- Transport protocols and congestion control in communication networks
- Cross-layer optimization for communication systems

## Common grouping axes

### By layer

- PHY
- MAC
- Network
- Transport
- Cross-layer

### By environment

- Terrestrial wireless
- Satellite / NTN
- UAV / aerial
- Vehicular / sidelink
- IoT / LPWAN

### By method

- Model-based control
- Optimization
- Learning-based
- Prediction-based
- Measurement / trace-driven

## Boundary cases

Use this skill if the paper's main contribution is still about a communication system, even if it uses ML.

Examples that should still trigger:

- DRL for Wi-Fi rate adaptation
- GNN for radio resource allocation
- LSTM for satellite link prediction
- learning-based congestion control for LEO

Prefer a different skill if the center of gravity is elsewhere:

- pure ML architecture research with communications as a toy application
- generic control theory without communications-specific literature
- software/API documentation rather than research papers
