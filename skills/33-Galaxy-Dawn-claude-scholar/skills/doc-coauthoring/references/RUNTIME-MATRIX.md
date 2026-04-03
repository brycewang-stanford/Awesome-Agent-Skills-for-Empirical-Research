# Runtime Matrix

## Claude Code / local filesystem available
- Prefer local markdown files.
- Use direct file edits instead of artifact-only assumptions.
- Use sub-agents for reader testing only when they are actually available.

## Claude.ai or app with artifacts
- Use artifacts when they improve iteration speed.
- Keep the document path or artifact identity explicit in the conversation.

## Connectors available
- Pull context from connected systems only after user consent.
- Summarize imported context before drafting.

## No connectors available
- Ask the user to paste or summarize the needed context.
- Do not imply that Slack / Drive / SharePoint can be read automatically.
