---
name: zotero-arxiv-daily-guide
description: "Guide to Zotero arXiv Daily for personalized daily paper recommendations"
metadata:
  openclaw:
    emoji: "📰"
    category: "literature"
    subcategory: "discovery"
    keywords: ["zotero", "arxiv", "daily-papers", "recommendations", "preprint", "discovery"]
    source: "wentor-research-plugins"
---

# Zotero arXiv Daily Guide

## Overview

Zotero arXiv Daily is a popular Zotero plugin with over 5,000 GitHub stars that delivers personalized daily paper recommendations from arXiv directly into your Zotero library. By analyzing the papers you already have in your collections, the plugin identifies your research interests and surfaces new preprints that are most relevant to your work.

The challenge of staying current with preprint literature is well known to researchers. ArXiv publishes thousands of new papers daily across dozens of categories, and manually scanning listings or relying solely on keyword alerts often results in information overload or missed relevant work. Zotero arXiv Daily addresses this by using your existing library as a profile of your interests, producing recommendations that improve as your library grows.

The plugin integrates naturally into the Zotero workflow. Recommended papers appear in a dedicated collection where you can review titles and abstracts, save promising papers to your working collections, and dismiss irrelevant suggestions. Over time the recommendation engine learns from your accept and dismiss decisions, refining its model of your interests.

## Installation and Setup

Install Zotero arXiv Daily through the standard Zotero plugin process:

1. Download the latest `.xpi` release from wentor-research-plugins/releases
2. In Zotero, go to Tools > Add-ons > gear icon > Install Add-on From File
3. Select the `.xpi` file and restart Zotero

Configure the plugin after installation:

- Open Zotero Preferences > arXiv Daily
- Select the arXiv categories relevant to your research (e.g., cs.AI, cs.CL, stat.ML, physics.comp-ph)
- Choose which Zotero collections to use as the basis for recommendations (your core research collections work best)
- Set the number of daily recommendations (10-30 is typical)
- Configure the schedule for fetching new recommendations (daily at a specific time or on-demand)
- Set up a dedicated Zotero collection where recommendations will appear

For enhanced recommendation quality, ensure your library collections are well-organized. The algorithm performs better when it can distinguish between your core research interests and peripheral references. Consider creating a dedicated collection of your most representative papers to serve as the recommendation seed.

## Core Features

**Personalized Recommendations**: The plugin analyzes titles, abstracts, authors, and citation patterns in your Zotero library to build a profile of your research interests. New arXiv submissions are scored against this profile and the top matches are presented as daily recommendations.

**Category Filtering**: Select specific arXiv categories to narrow the recommendation scope. This prevents the system from suggesting papers in completely unrelated fields while still allowing cross-disciplinary discoveries within your selected categories.

**Daily Digest View**: Recommendations appear in a dedicated Zotero collection organized by date. Each entry includes the paper title, authors, abstract, arXiv identifier, and a relevance score indicating how closely it matches your library profile.

**Quick Actions**: For each recommended paper, you can:
- Save to a working collection with one click
- Open the full paper on arXiv
- Download the PDF directly to Zotero
- Dismiss the recommendation (improves future suggestions)
- Add tags for later organization

**Trend Detection**: The plugin can highlight papers that are receiving unusual attention in your field based on early citation velocity and social media mentions. This helps you identify potentially important work before it becomes widely known.

**Author Tracking**: When the plugin detects papers by authors who are frequently cited in your library, it flags these with higher priority. This ensures you never miss new work from the researchers most relevant to your field.

## Research Workflow Integration

**Morning Review Routine**: Start your research day by spending 10-15 minutes reviewing the daily arXiv recommendations. Scan titles and abstracts, save promising papers to a "To Read" collection, and dismiss irrelevant ones. This disciplined approach keeps you current without consuming excessive time.

**Literature Review Enhancement**: During active literature review phases, increase the number of daily recommendations and expand the arXiv categories. The plugin helps identify relevant preprints that may not yet appear in traditional databases, giving your review a more comprehensive and timely scope.

**Collaborative Discovery**: Share your recommended papers collection with lab members through a Zotero group library. This creates a collective discovery mechanism where the entire group benefits from each member's library-driven recommendations.

**Research Trend Monitoring**: Track which topics appear frequently in your recommendations over weeks and months. Shifts in the recommendation patterns can signal emerging trends in your field, helping you anticipate where the research community is heading.

**Optimizing Recommendation Quality**:
- Maintain a well-curated "seed" collection of your most important papers
- Regularly dismiss irrelevant recommendations to refine the algorithm
- Update your arXiv category selections as your interests evolve
- Add newly published papers from your own group to keep the profile current
- Review recommendations from adjacent categories periodically for cross-disciplinary insights

## Configuring Notification Preferences

Control how and when you receive recommendation alerts:

- **Desktop Notifications**: Enable system notifications when new recommendations arrive
- **Batch Mode**: Accumulate recommendations and review them at a scheduled time
- **Threshold Filtering**: Only show recommendations above a configurable relevance score
- **Keyword Highlighting**: Specify key terms to highlight in recommended paper titles and abstracts

For researchers who find the default recommendation volume too high, set a higher relevance threshold to receive only the most closely matched papers. Conversely, those in rapidly moving fields may want to lower the threshold and increase the daily count to ensure broad coverage.

## References

- GitHub Repository: wentor-research-plugins
- arXiv API Documentation: https://info.arxiv.org/help/api
- Zotero Plugin Directory: https://www.zotero.org/support/plugins
- arXiv Category Taxonomy: https://arxiv.org/category_taxonomy
