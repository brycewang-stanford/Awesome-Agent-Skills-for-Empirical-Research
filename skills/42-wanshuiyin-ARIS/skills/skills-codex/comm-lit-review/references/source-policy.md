# Source Policy

## Default priority

1. `IEEE Xplore`
2. `ScienceDirect`
3. `ACM Digital Library`
4. Domain-appropriate primary venues and broader web only when the first three are insufficient
5. Preprints only when necessary

## Database intent

- `IEEE Xplore`: best default for wireless, communications, PHY/MAC, networking, signal processing, NTN, and protocol work.
- `ScienceDirect`: useful for communications journals, Computer Networks, Ad Hoc Networks, Physical Communication, and systems papers published through Elsevier venues.
- `ACM Digital Library`: important second-line source for networking systems, transport protocols, mobile systems, and Internet measurement once the first two tiers are exhausted.

## When to widen beyond IEEE, ScienceDirect, and ACM

Widen only if one of these is true:

- the topic is heavily systems-oriented and canonical papers live in ACM or USENIX venues
- the recent frontier has not yet appeared in the three preferred databases
- the user explicitly asks for a broader sweep

When widening, prefer:

- `dl.acm.org`
- official conference pages
- publisher DOI pages
- authors' public PDFs that correspond to already-identified formal papers
- carefully targeted web search rather than open-ended browsing

## Search layering

Always layer the search in two dimensions:

1. **database layer**
   - IEEE
   - ScienceDirect
   - ACM
   - broader web
2. **venue layer within each database**
   - top journals and top conferences
   - mainstream strong venues
   - all other relevant formal venues

Do not jump straight to broad web search if the topic can still be served by a higher database or venue tier.

## Venue policy

Follow [venue-tiering.md](venue-tiering.md).

The default behavior is:

- look for Tier A papers first
- expand to Tier B if the set is too small
- expand to Tier C if the topic is niche or the user wants broader coverage

If the user explicitly asks for `top venues only`, `top journals only`, or `top conferences only`, treat Tier A as a hard filter rather than a ranking hint.

## Publication policy

- Prefer peer-reviewed journals and major conferences.
- Label workshop papers as `workshop`.
- Label arXiv-only or author-hosted versions as `preprint`.
- If both a preprint and formal version exist, cite the formal version first.

## Time-window policy

If the user does not specify a year range:

- include a short foundational set
- include a recent set
- separate them explicitly in the synthesis

Recommended default split:

- `foundational`: before 2022
- `recent`: 2022 to present

## Search-query guidance

Build queries from:

- system name: `LEO`, `NTN`, `Wi-Fi 7`, `NR sidelink`
- technical problem: `rate adaptation`, `congestion control`, `beam hopping`
- layer name: `PHY`, `MAC`, `transport`, `cross-layer`
- method family if relevant: `RL`, `learning-based`, `optimization`, `prediction`

Avoid overly broad queries such as:

- `wireless AI`
- `satellite network paper`

Prefer tighter queries such as:

- `LEO satellite congestion control IEEE`
- `NTN rate adaptation IEEE Xplore`
- `Wi-Fi rate adaptation ScienceDirect`
