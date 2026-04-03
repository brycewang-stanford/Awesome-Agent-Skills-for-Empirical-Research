# AI Skills

A collection of reusable skills (prompts/instructions) for AI agents.

## What Are Skills?

Skills are structured prompts that give AI agents specialized capabilities. They define:
- What questions to ask users
- What sources to use
- How to format output
- What guardrails to enforce

Skills are agent-agnostic - they work with any AI that can follow instructions and has the required tools (e.g., browser automation).

## Available Skills

| Skill | Description |
|-------|-------------|
| [Economist Data Skill](Skills/README.md) | Fetch economic data from authoritative sources with enforced data specification decisions |

## Usage

1. Choose a skill from the `Skills/` directory
2. Load the skill's `.md` file into your AI agent
3. Follow the skill's setup and usage instructions

## Contributing

To add a new skill:
1. Create a new `.md` file in `Skills/`
2. Include a README explaining the skill's goals
3. Follow the structure of existing skills

## License

MIT
