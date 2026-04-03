---
name: auto-deep-research-guide
description: "Automated deep research tool for thorough topic investigation"
version: 1.0.0
author: wentor-community
source: "wentor-research-plugins"
metadata:
  openclaw:
    category: "research"
    subcategory: "deep-research"
    emoji: "🔍"
    keywords:
      - deep-research
      - automated-investigation
      - topic-exploration
      - research-synthesis
      - iterative-search
      - knowledge-mapping
---

# Auto Deep Research Guide

A skill for conducting automated, in-depth research investigations that go beyond surface-level searches to produce comprehensive, well-sourced reports on any academic topic. Based on Auto-Deep-Research (1K stars), this skill implements iterative search-analyze-refine cycles that progressively deepen understanding of a research topic.

## Overview

Deep research differs from simple literature search in its depth and synthesis. Rather than returning a list of papers, deep research produces a structured understanding of a topic: its history, current state, key debates, methodological approaches, open questions, and future directions. This skill automates the iterative process that expert researchers perform manually, cycling through search, reading, analysis, and question refinement until a satisfactory depth of understanding is achieved.

The approach is particularly valuable for researchers entering a new field, preparing comprehensive literature reviews, writing grant proposals that require thorough background knowledge, or advising students on topics adjacent to their own expertise.

## Deep Research Methodology

The automated deep research process follows a structured methodology:

**Phase 1: Topic Decomposition**
- Parse the initial research question into its core concepts
- Identify the disciplinary context and relevant subfields
- Generate a preliminary topic map with major themes and subtopics
- Formulate 5-10 seed questions that span the topic's breadth
- Establish depth targets for each subtopic (survey, working knowledge, expert)

**Phase 2: Breadth-First Exploration**
- Execute seed questions as searches across academic databases
- Collect and rank results by relevance, citation impact, and recency
- Read abstracts and identify the most informative sources for each subtopic
- Build a preliminary bibliography organized by subtopic
- Identify key authors, institutions, and publication venues for the topic

**Phase 3: Depth-First Investigation**
- For each subtopic, select the highest-quality sources for detailed analysis
- Extract key claims, evidence, and methodological details
- Identify points of consensus and disagreement among sources
- Note methodological trends and their evolution over time
- Generate follow-up questions based on gaps in understanding

**Phase 4: Iterative Refinement**
- Use follow-up questions to drive additional targeted searches
- Seek out primary sources cited by secondary sources
- Look for contradictory evidence or alternative perspectives
- Update the topic map with newly discovered themes
- Continue until reaching diminishing returns (saturation)

**Phase 5: Synthesis and Reporting**
- Organize findings into a coherent narrative structure
- Distinguish between established knowledge, active debates, and speculation
- Provide evidence quality assessments for key claims
- Identify the most impactful open questions and research opportunities
- Generate a structured report with full citations

## Search Strategy Automation

The skill automates several sophisticated search strategies:

**Query Expansion**
- Use LLMs to generate semantically related query variations
- Apply field-specific vocabulary and acronym expansion
- Include both current terminology and historical terms for the same concepts
- Generate queries in multiple languages when the topic has global research activity
- Adapt query complexity based on the number of results returned

**Source Triangulation**
- Search multiple independent databases to avoid source bias
- Cross-reference findings from different research traditions
- Check for replication of key findings across independent studies
- Weight evidence from systematic reviews and meta-analyses more heavily
- Identify and note where evidence comes from a single research group

**Citation Chain Analysis**
- Follow backward citations from key papers to find foundational work
- Follow forward citations to find the latest developments
- Identify citation clusters indicating distinct research communities
- Detect bridge papers connecting different research threads
- Map the chronological evolution of ideas through citation chains

## Report Generation

The final output is a structured research report:

**Report Structure**
- Executive summary with key findings and confidence levels
- Historical background tracing the topic's development
- Current state of knowledge organized by subtopic
- Methodological landscape describing dominant and emerging approaches
- Key debates and unresolved questions with evidence for each position
- Future directions and promising research opportunities
- Complete bibliography organized by subtopic and relevance

**Quality Indicators**
- Each claim is annotated with its evidence strength (strong, moderate, limited)
- Conflicting evidence is presented alongside each other with analysis
- Gaps in the literature are explicitly flagged
- The report distinguishes between empirical findings and theoretical arguments
- Sources are evaluated for potential bias or conflicts of interest

## Customization Options

The deep research process can be customized for different use cases:

**Grant Proposal Background** - Emphasize recent developments, open questions, and potential impact
**Literature Review** - Emphasize comprehensiveness, systematic coverage, and gap identification
**New Field Entry** - Emphasize foundational concepts, key terminology, and landmark papers
**Thesis Background** - Emphasize the specific niche within the broader field and its context
**Policy Brief** - Emphasize applied findings, real-world implications, and evidence quality

## Integration with Research-Claw

This skill leverages and feeds into other Research-Claw capabilities:

- Uses literature search skills for database queries
- Feeds results to paper-to-agent skill for detailed paper analysis
- Outputs structured bibliographies compatible with citation management skills
- Connects with writing skills for drafting review sections
- Stores research reports in the local knowledge base for future reference

## Best Practices

- Always start with a clear, well-defined research question
- Set a time budget and scope limit before beginning to prevent endless exploration
- Review and redirect the automated process periodically rather than running fully unattended
- Verify key claims by reading the original sources, not just relying on extracted summaries
- Save intermediate results at each phase to enable resuming if interrupted
- Use the generated report as a starting point for human analysis, not as a finished product
