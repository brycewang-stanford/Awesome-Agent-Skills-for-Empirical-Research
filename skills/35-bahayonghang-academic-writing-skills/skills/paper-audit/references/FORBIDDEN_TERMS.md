# FORBIDDEN_TERMS.md

Protected terms and constructs that **must never be modified** without explicit user confirmation.
These rules apply to all audit modes (`quick-audit`, `deep-review`, `gate`, `polish`, and compatibility aliases).

---

## 1. LaTeX Command Protection List

The following LaTeX commands must **never** be altered in content, spelling, or structure:

| Command | Reason | Example |
|---------|--------|---------|
| `\cite{key}` | Bibliography reference — changing key breaks citation | `\cite{lecun1998}` |
| `\citep{key}` | Parenthetical citation | `\citep{vaswani2017}` |
| `\citet{key}` | Textual citation | `\citet{hinton2006}` |
| `\ref{label}` | Cross-reference — changing breaks link | `\ref{fig:arch}` |
| `\eqref{label}` | Equation reference | `\eqref{eq:loss}` |
| `\autoref{label}` | Auto-typed reference | `\autoref{tab:results}` |
| `\cref{label}` | cleveref reference | `\cref{fig:overview}` |
| `\Cref{label}` | cleveref uppercase reference | `\Cref{tab:ablation}` |
| `\pageref{label}` | Page reference | `\pageref{sec:method}` |
| `\hyperref[label]{text}` | Hyperlink reference | `\hyperref[sec:exp]{Section 3}` |
| `\label{key}` | Label definition — changing breaks all refs | `\label{fig:arch}` |
| `\bibliography{file}` | Bibliography file reference | `\bibliography{references}` |
| `\bibliographystyle{style}` | Bibliography style | `\bibliographystyle{plain}` |
| `\input{file}` | File inclusion | `\input{sections/intro}` |
| `\include{file}` | File inclusion with page break | `\include{chapter1}` |

---

## 2. Typst Command Protection List

| Command | Reason | Example |
|---------|--------|---------|
| `@key` | Bibliography citation | `@lecun1998` |
| `#cite(<key>)` | Citation function | `#cite(<vaswani2017>)` |
| `#ref(<label>)` | Cross-reference | `#ref(<fig:arch>)` |
| `<label>` | Label definition | `<fig:overview>` |
| `#include "file"` | File inclusion | `#include "sections/intro.typ"` |
| `#bibliography("file")` | Bibliography file | `#bibliography("refs.bib")` |

---

## 3. Math Environment Protection List

These environments contain mathematical content — **never** modify the LaTeX/Typst code inside them:

### LaTeX Math Environments
- `$...$` — Inline math
- `$$...$$` — Display math (deprecated but protected)
- `\(...\)` — Inline math (preferred)
- `\[...\]` — Display math (preferred)
- `\begin{equation}...\end{equation}`
- `\begin{equation*}...\end{equation*}`
- `\begin{align}...\end{align}`
- `\begin{align*}...\end{align*}`
- `\begin{aligned}...\end{aligned}`
- `\begin{gather}...\end{gather}`
- `\begin{gather*}...\end{gather*}`
- `\begin{multline}...\end{multline}`
- `\begin{cases}...\end{cases}`
- `\begin{array}...\end{array}`
- `\begin{matrix}...\end{matrix}` (and variants: pmatrix, bmatrix, vmatrix)

### Typst Math Environments
- `$...$` — Inline math
- `$ ... $` — Display math (with spaces)

### Why Protected
Math expressions may contain domain-specific notation. Modifying symbols, operators, or
indices can silently change mathematical meaning without being syntactically wrong.

---

## 4. Domain Terminology Freeze List

These terms appear frequently in academic writing but have **precise technical meanings**.
Do **not** suggest synonyms or rewrites without user confirmation:

### Computer Science / Machine Learning
- **gradient descent** (not "slope descent" or "derivative minimization")
- **backpropagation** (not "backward propagation algorithm")
- **attention mechanism** / **self-attention** / **cross-attention**
- **transformer** (architecture, capitalized in "Transformer" when referring to the architecture)
- **perplexity** (NLP metric — not "confusion" or "uncertainty")
- **overfitting** / **underfitting** / **generalization gap**
- **hyperparameter** (not "meta-parameter" or "configuration parameter" in ML context)
- **fine-tuning** / **pre-training** / **transfer learning**
- **tokenization** / **tokenizer** / **subword tokenization**
- **embedding** (vector representation — not "encoding" interchangeably)
- **batch normalization** / **layer normalization** / **instance normalization**
- **dropout** (regularization technique)
- **cross-entropy loss** / **KL divergence** / **ELBO**
- **precision** / **recall** / **F1 score** (classification metrics — not synonyms)
- **BLEU** / **ROUGE** / **METEOR** (evaluation metrics — not interchangeable)

### Mathematics / Statistics
- **convex** / **concave** (not interchangeable)
- **bijective** / **injective** / **surjective** (not interchangeable)
- **stochastic** (not synonymous with "random" in all contexts)
- **expectation** / **variance** / **covariance** (statistical terms)
- **null hypothesis** / **p-value** / **statistical significance**
- **Monte Carlo** (proper noun — always capitalized)

### General Academic Terms
- **ablation study** (not "component analysis" or "removal experiment")
- **state-of-the-art** / **SOTA** (not "best-performing" without context)
- **baseline** (comparison reference — not synonymous with "default")
- **benchmark** (standardized evaluation — not synonymous with "test")
- **corpus** / **corpora** (linguistic dataset — not "dataset" in all contexts)

---

## 5. Usage Rules for Tools

When an audit module encounters any of the above:

1. **SKIP**: Do not flag the protected construct as an issue.
2. **CONTEXT-ONLY**: Surrounding text may be analyzed, but the protected term/command itself is off-limits.
3. **CONFIRM**: If a change to a protected term is genuinely needed (e.g., broken `\ref` with no matching `\label`), report it as an **issue** but do **not** auto-fix.
4. **REPORT**: Reference-integrity issues (`\ref` with no `\label`) should be reported via `check_references.py`, not silently corrected.

---

## 6. Audit Module Compliance

| Module | Must Skip | Must Report |
|--------|-----------|-------------|
| `analyze_grammar.py` | All math environments, all `\cite`, `\ref`, `\label` | None |
| `analyze_logic.py` | Math environments, citation content | Structural logic issues only |
| `analyze_sentences.py` | All math environments | Sentence-level issues in prose |
| `deai_check.py` | Math environments, citation keys | AI-generated patterns in prose |
| `check_format.py` | Math environments, citations | Format violations in metadata |
| `check_references.py` | Nothing (this is the reporter) | All broken/missing references |
| `verify_bib.py` | Nothing (this is the reporter) | All bib integrity issues |
| `visual_check.py` | All text content | Layout/visual issues only |

---

*Last updated: 2026-02-27*
