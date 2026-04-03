---
name: generate-exam
description: Generate exams conversationally using Claude Code (no API key needed)
---

# Generate Exam (Conversational Mode)

Generate exams directly through Claude Code conversation - perfect for Max users who don't need API keys.

## How to Use

Just ask me to generate an exam! For example:

- "Generate a midterm exam with 10 questions"
- "Create a final exam on regression analysis"
- "Make a quick 5-question quiz"

I'll generate the exam, validate it, and save it for you.

<system>
When the user requests exam generation, follow these steps:

1. **Gather Requirements** (if not provided):
   - Exam type (midterm, final, practice, quiz)
   - Number of questions (default: 10)
   - Difficulty (easy, medium, hard)
   - Topics to cover
   - Duration
   - Question types

2. **Build Prompt**:
```javascript
import { buildPrompt } from '../../../teaching/generators/exam-conversational.js';

const promptData = buildPrompt({
  type: 'midterm',
  questionCount: 10,
  difficulty: 'medium',
  topics: ['regression', 'ANOVA'],
  durationMinutes: 60,
  questionTypes: {
    'multiple-choice': 0.6,
    'short-answer': 0.3,
    'essay': 0.1
  }
});

// Show the prompt to understand requirements
console.log('📋 Generating exam with these requirements:');
console.log(`  Type: ${promptData.options.type}`);
console.log(`  Questions: ${promptData.options.questionCount}`);
console.log(`  Difficulty: ${promptData.options.difficulty}`);
console.log(`  Topics: ${promptData.options.topics.join(', ') || 'General'}`);
```

3. **Generate Exam Content**:
Use the prompt from step 2 to generate exam JSON. The exam should be valid JSON matching the structure:

```json
{
  "title": "Midterm Exam - Course Name",
  "exam_type": "midterm",
  "duration_minutes": 60,
  "instructions": "General instructions",
  "questions": [
    {
      "id": "Q1",
      "type": "multiple-choice",
      "text": "Question text",
      "options": ["Option A", "Option B", "Option C", "Option D"],
      "points": 10,
      "difficulty": "medium",
      "topic": "topic name"
    }
  ],
  "answer_key": {
    "Q1": "B"
  },
  "formula_sheet": "LaTeX formulas (if requested)"
}
```

4. **Validate and Process**:
```javascript
import { validateExam, saveExam, displaySummary } from '../../../teaching/generators/exam-conversational.js';

// Validate the generated content
const exam = validateExam(generatedContent, { strict: false });

// Check validation
if (!exam.validation.isValid) {
  console.error('❌ Validation failed:');
  exam.validation.errors.forEach(err => {
    console.error(`  ${err.field}: ${err.message}`);
  });
  return;
}

// Display summary
displaySummary(exam);

// Save to file
const filepath = saveExam(exam);
console.log(`\n📁 Saved to: ${filepath}`);
```

5. **Show Results**:
Display the exam summary with:
- Exam type and statistics
- Question breakdown by type
- Sample questions (first 3)
- Validation warnings (if any)
- File path where it was saved

## Example Interactions

### Example 1: Basic Request
```
User: Generate a midterm exam with 10 questions