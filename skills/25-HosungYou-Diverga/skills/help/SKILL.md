---
name: help
description: |
  Diverga help guide - displays all 24 agents across 9 categories, commands, and usage examples.
  Triggers: help, guide, how to use, 도움말
version: "12.0.1"
---

# /diverga:help

**Version**: 2.0.0
**Trigger**: `/diverga:help`

## Description

Displays comprehensive guide for Diverga, including all 24 agents across 9 categories, commands, and usage examples.

## Output

When user invokes `/diverga:help`, display:

```
╔══════════════════════════════════════════════════════════════════╗
║                     Diverga v11.0 Help                           ║
║         AI Research Assistant - 24 Agents, 9 Categories          ║
╚══════════════════════════════════════════════════════════════════╝

┌─────────────────────────────────────────────────────────────────┐
│                        QUICK START                               │
├─────────────────────────────────────────────────────────────────┤
│ Just describe your research:                                     │
│   "I want to conduct a meta-analysis on AI in education"        │
│   "Help me design a qualitative study"                          │
│   "메타분석 연구를 시작하고 싶어"                                  │
│                                                                  │
│ Diverga auto-detects context and activates relevant agents.      │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                         COMMANDS                                 │
├─────────────────────────────────────────────────────────────────┤
│ /diverga:setup          Initial configuration wizard            │
│ /diverga:doctor         System diagnostics & health check       │
│ /diverga:help           This help guide                         │
│ /diverga:meta-analysis  Meta-analysis workflow (C5)             │
│ /diverga:humanize       Humanization pipeline (G5+G6+F5)       │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│              CATEGORY A: FOUNDATION (3 agents)                   │
├─────────────────────────────────────────────────────────────────┤
│ diverga:a1  ResearchQuestionRefiner     Refine research Qs      │
│ diverga:a2  TheoreticalFrameworkArchitect  Frameworks + Critique │
│             + Visualization (absorbed A3, A6)                    │
│ diverga:a5  ParadigmWorldviewAdvisor    Ontology + Ethics       │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│              CATEGORY B: EVIDENCE (2 agents)                     │
├─────────────────────────────────────────────────────────────────┤
│ diverga:b1  LiteratureReviewStrategist  Literature search       │
│ diverga:b2  EvidenceQualityAppraiser    RoB, GRADE appraisal    │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│         CATEGORY C: DESIGN & META-ANALYSIS (4 agents)            │
├─────────────────────────────────────────────────────────────────┤
│ diverga:c1  QuantitativeDesignConsultant  Quant design          │
│             + Materials + Sampling (absorbed C4, D1)             │
│ diverga:c2  QualitativeDesignConsultant   Qual design           │
│             + Ethnography + Action Research (absorbed H1, H2)    │
│ diverga:c3  MixedMethodsDesignConsultant  Mixed methods         │
│ diverga:c5  MetaAnalysisMaster ⭐         Meta-analysis lead    │
│             + Data/Effect/Error/Sensitivity (absorbed C6,C7,B3,E5)│
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│            CATEGORY D: DATA COLLECTION (2 agents)                │
├─────────────────────────────────────────────────────────────────┤
│ diverga:d2  DataCollectionSpecialist    Interview + Observation  │
│             (absorbed D3, renamed)                               │
│ diverga:d4  MeasurementInstrumentDeveloper  Instrument dev      │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│              CATEGORY E: ANALYSIS (3 agents)                     │
├─────────────────────────────────────────────────────────────────┤
│ diverga:e1  QuantitativeAnalysisGuide   Statistical guidance    │
│             + Code Gen + Sensitivity (absorbed E4, E5)           │
│ diverga:e2  QualitativeCodingSpecialist  Qualitative coding     │
│ diverga:e3  MixedMethodsIntegration     Integration methods     │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│               CATEGORY F: QUALITY (1 agent)                      │
├─────────────────────────────────────────────────────────────────┤
│ diverga:f5  HumanizationVerifier        Verify humanization     │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│            CATEGORY G: COMMUNICATION (4 agents)                  │
├─────────────────────────────────────────────────────────────────┤
│ diverga:g1  JournalMatcher              Match journals          │
│ diverga:g2  PublicationSpecialist       Writing + Review + PreReg│
│             + Quality (absorbed G3, G4, F1, F2, F3)             │
│ diverga:g5  AcademicStyleAuditor        AI pattern detection    │
│ diverga:g6  AcademicStyleHumanizer      Humanize AI text        │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│              CATEGORY I: SYSTEMATIC REVIEW (4 agents)            │
├─────────────────────────────────────────────────────────────────┤
│ diverga:i0  ReviewPipelineOrchestrator  Pipeline coordination   │
│ diverga:i1  PaperRetrievalAgent         Multi-database fetch    │
│ diverga:i2  ScreeningAssistant          AI-PRISMA screening     │
│ diverga:i3  RAGBuilder                  Vector DB + Parallel    │
│             (absorbed B5)                                        │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│              CATEGORY X: CROSS-CUTTING (1 agent)                 │
├─────────────────────────────────────────────────────────────────┤
│ diverga:x1  ResearchGuardian            Ethics + Bias detection │
│             (absorbed A4, F4)                                    │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                    HUMAN CHECKPOINTS                             │
├─────────────────────────────────────────────────────────────────┤
│ 🔴 REQUIRED (System STOPS):                                      │
│    CP_PARADIGM       Research paradigm selection                 │
│    CP_METHODOLOGY    Methodology approval                        │
│                                                                  │
│ 🟠 RECOMMENDED (System PAUSES):                                  │
│    CP_THEORY         Theory framework selection                  │
│    CP_DATA_VALIDATION Data extraction validation                │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                   MODEL ROUTING                                  │
├─────────────────────────────────────────────────────────────────┤
│ HIGH (Opus):   A1,A2,A5,C1,C2,C3,C5,D4,E1,E2,E3,G6,I0         │
│ MEDIUM (Sonnet): B1,B2,D2,G1,G2,G5,X1,I1,I2                     │
│ LOW (Haiku):   F5,I3                                             │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                 AUTO-TRIGGER KEYWORDS                            │
├─────────────────────────────────────────────────────────────────┤
│ "research question", "RQ", "연구 질문"        → diverga:a1      │
│ "theoretical framework", "이론적 프레임워크"  → diverga:a2      │
│ "critique", "devil's advocate", "반론"       → diverga:a2      │
│ "IRB", "ethics", "연구 윤리"                 → diverga:x1      │
│ "meta-analysis", "메타분석", "효과크기"       → diverga:c5      │
│ "systematic review", "PRISMA"               → diverga:b1      │
│ "qualitative", "interview", "질적 연구"      → diverga:c2      │
│ "ethnography", "action research"            → diverga:c2      │
└─────────────────────────────────────────────────────────────────┘

For more info: https://github.com/HosungYou/Diverga
```

## Direct Agent Invocation

Users can invoke specific agents:

```
diverga:c5   # Invoke Meta-Analysis Master directly
diverga:a1   # Invoke Research Question Refiner
```

## Implementation Notes

- Help content adapts to user's language preference
- Agent recommendations based on detected research context
- Links to GitHub for full documentation
