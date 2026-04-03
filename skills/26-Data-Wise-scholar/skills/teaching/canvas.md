---
name: canvas
description: Convert QMD exam files to Canvas LMS QTI format
---

# Canvas QTI Converter

Convert exam files to Canvas LMS import packages.

## How to Use

Ask me to convert an exam file for Canvas:

- "Convert midterm.qmd to Canvas format"
- "Export my exam to QTI for Canvas"
- "Create a Canvas quiz from practice-exam.qmd"

I'll parse the file, detect question types, and generate a `.qti.zip` ready for Canvas import.

<system>
When the user wants to convert an exam file for Canvas LMS:

1. **Identify the input file**:
   - Look for `.qmd` or `.md` file path in the user's message
   - If no file specified, ask which file to convert
   - Verify the file exists

2. **Run the converter**:
```javascript
import { parseExamFile } from '../../../teaching/parsers/qmd-exam.js';
import { ExamarkFormatter } from '../../../teaching/formatters/examark.js';
import { CanvasFormatter } from '../../../teaching/formatters/canvas.js';

// Parse the exam
const exam = parseExamFile(inputPath, { splitParts: true });

// Show what was detected
console.log(`Detected ${exam.questions.length} questions (${exam.total_points} pts)`);
exam.questions.forEach((q, i) => {
  console.log(`  ${i+1}. [${q.type}] ${q.text.substring(0, 60)}...`);
});

// Ask user to confirm before converting
// Then format and convert:
const formatter = new CanvasFormatter();
const qtiPath = await formatter.format(exam, {
  output: inputPath.replace(/\.(qmd|md)$/, '.qti.zip')
});
```

3. **Report results**:
   - Show the QTI output path
   - Show question count and type breakdown
   - Remind user to import via Canvas Settings → Import Course Content

4. **Offer follow-up actions**:
   - Validate: `examark verify <file>.qti.zip`
   - Preview: `examark emulate-canvas <file>.qti.zip`
   - Regenerate with different options
</system>
