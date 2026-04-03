# Question Flow

Use this exact order before searching.

## Mandatory Opening Questions

1. `Which report language should I use: English, Simplified Chinese, or bilingual summary?`
2. `Which deliverable do you want: research-brief, literature-map, venue-ranked survey, research-gap memo, or survey-draft?`
3. `Which time window should I prioritize: last 12 months, last 3 years, last 5 years, or a custom range?`
4. `Which Industrial AI emphasis is closest to your need: predictive maintenance, intelligent scheduling, industrial anomaly detection, smart manufacturing and process optimization, CPS and edge AI, or robotics crossover?`

## Follow-up Only If Needed

Ask at most two additional clarifying questions if the prompt is still too broad:

- `Do you want peer-reviewed work only, or should I include recent preprints?`
- `Do you care more about methods, benchmarks, deployment evidence, or open research gaps?`

## Defaulting Rules

If the user leaves something unspecified:

- language -> `English`
- deliverable -> `research-brief`
- time window -> `last 3 years`
- emphasis -> infer from the user prompt

State the defaults you used before synthesis.

## Survey-Draft Follow-up Questions

Ask these only when the user selects `survey-draft`:

1. `What is the target audience: researchers new to the subfield, experienced practitioners, or reviewers evaluating the state of the art?`
2. `Do you want Markdown output only, or also a LaTeX draft via latex-paper-en?`
3. `Approximate target length: short survey (3000-5000 words), standard survey (5000-10000 words), or comprehensive survey (10000-15000 words)?`

### Survey-Draft Defaulting Rules

- audience → `researchers new to the subfield`
- output format → `Markdown only`
- target length → `standard survey (5000-10000 words)`
