# Spec-Driven Development (SDD) Framework Extraction

## Core Philosophy (Image 5, 13)
- **Clarity before Code:** Invest time to understand *what* to build.
- **Iterative Refinement:** Capture the evolution of the idea.
- **Code via Docs:** Move from ephemeral chat to persistent, shareable documents.
- **Goal:** AI under control. Specification driven lifecycle.

## The Workflow (Image 3, 6, 15, 17)
1.  **The Vibe (Exploration):** Use "vibe coding" (casual chat) to explore and experiment. Get a handle on what you really want.
2.  **Intent:** "Spec-driven development" starts here. The output of "The Vibe" becomes the input for the Spec.
3.  **Opinionated Workflow (The "Spec" Loop):**
    *   **Requirements:** Generate concrete, measurable requirements (EARS syntax).
    *   **Design:** Create initial design (Architecture, Data Models, Interfaces).
    *   **Tasks:** Define sequential, testable tasks.
    *   *Loop:* Iterate, Refine, Approval at each step.
4.  **Implementation:**
    *   Generate code from tasks.
    *   Test/QA.
    *   Fix Issues (Loop back if needed).
5.  **Deployment & Maintenance.**

## Detailed Components

### 1. Context & Steering (Image 1, 7)
- **Concept:** "Steering Documents" align the AI with the Intent.
- **Smart Context:** Automatic, Pattern Match, or Manual.
- **Strategies:**
    - Start small (core needs only).
    - Use descriptive names (e.g., `api-rest-conventions.md`).
    - **Examples are key:** Code snippets, input/outputs, style guides.
    - **Security First:** No secrets in steering docs.

### 2. Requirements (Image 9, 10, 18, 22)
- **Format:** **EARS** (Easy Application Requirements Syntax). Optimized for LLMs.
    - *Ubiquitous:* `<system> shall <response>`
    - *Event-Driven:* `WHEN <trigger> then <system> shall <response>`
    - *Unwanted:* `IF <unwanted> THEN <system> shall <response>`
    - *State-Driven:* `WHILE <state>, <system> shall <response>`
    - *Optional:* `WHERE <feature>, <system> shall <response>`
- **Refinement:**
    - **Review:** Get stakeholder feedback.
    - **Identify Gaps:** Missing scenarios?
    - **Clarify Ambiguities:** Resolve vague/conflicting reqs.
    - **Edge Cases:** Add missing details and error handling.
- **Properties:** Define invariants/correctness properties. "Universal statements about how system should behave" (Image 18).

### 3. Design (Image 8, 20, 21)
- **Content:** Architecture, Components, Interfaces, Data Models, Error Handling, Test Strategy, Security, Perf.
- **Refinement:**
    - **Include Examples:** Help steer the AI.
    - **Edit Ruthlessly:** LLMs over-engineer. Cut the fluff.
    - **Check Missing Items:** Components or details dropped?
    - **Alignment:** Does it match steering?
    - **Circular Dependencies:** Watch out for them. Fix via Interface Extraction, Layering, or Decoupling (Events).

### 4. Tasks (Image 2, 4, 14, 41)
- **Structure:**
    - **Two-Level Max:** Top-level tasks + sub-tasks. No deep nesting.
    - **Logical Grouping:** Meaningful categories.
    - **Sequential:** Build on previous work.
    - **Traceability:** Link tasks back to Requirement IDs (e.g., `Requirements: 1.1, 5.4`).
- **Dependency Management:**
    - **Technical:** Components that must exist first (e.g., DB models before endpoints).
    - **Logical:** Features that conceptually build on others (e.g., User Reg before Profile Edit).
    - **Data:** Tasks requiring specific state (e.g., Transaction history requires Transaction data).
- **Prioritization:**
    - **Core First:** Essential functionality.
    - **Risk First:** Uncertain/complex tasks early.
    - **Value First:** High value, testable quickly.

## Comparison (Image 19)
- **vs TDD:** SDD is higher level (business reqs + system design).
- **vs Waterfall:** SDD is iterative within phases. Living docs. Optimized for feature-level dev.
- **vs BDD:** SDD uses explicit requirements gathering (EARS) + AI-focused structure.

## Iteration & Maintenance (Image 22)
**Triggers for updating your specification:**
1.  **Clarification:** Minor updates for precision (no functional change).
2.  **Changes:** New requirements or modifications to existing ones.
3.  **Discoveries:** Implementation details (tech constraints) found during coding that force design changes.
4.  **Technical Constraints:** Library limitations, performance issues, security concerns found during generation.
5.  **Integration Challenges:** Data format mismatches, auth issues, interface updates.
6.  **Feedback:** User feedback, accessibility, mobile support issues.

## Artifacts to Generate
- `spec/intent.md`
- `spec/requirements.md` (EARS)
- `spec/design.md`
- `spec/tasks.md`
- `steering/*.md` (Context)
