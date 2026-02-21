# Grades

## Grade Types

### Lesson Grade
- Created when a lesson is graded (transition to `:graded` state).
- One per student per lesson.
- `percent` calculated via linear interpolation between lesson's min/max point thresholds.

### Bonus Grade
- Manually created by teacher via a modal form.
- Has a name (e.g., "Great presentation"), percent (0-100% via slider), and is tied to a student+subject.
- Can be created from the active lesson view or the grade detail view.

### Overall Grade
- One per student per subject. Upserted (conflict on student_id + subject_id).
- Calculated as the **simple average** of all lesson_grade percents + all bonus_grade percents for that student+subject.
- Recalculated whenever: a lesson is graded/re-graded, a lesson is deleted, or a bonus grade is created/deleted.

## German Grade Scale

Percent values are formatted as German school grades (1+ through 6):

| Min % | Grade |
|-------|-------|
| 98%   | 1+    |
| 95%   | 1     |
| 92%   | 1-    |
| 87%   | 2+    |
| 82%   | 2     |
| 77%   | 2-    |
| 72%   | 3+    |
| 68%   | 3     |
| 62%   | 3-    |
| 57%   | 4+    |
| 52%   | 4     |
| 47%   | 4-    |
| 42%   | 5+    |
| 37%   | 5     |
| 25%   | 5-    |
| 0%    | 6     |

Grades are also displayed as percentages (e.g., "75%").

## Linear Grade Calculation

```
percent = (student_points - min) / (max - min)
```

Edge cases:
- `min == max`: result is 0.0
- `max < min`: result is 1.0 (everyone gets full marks)
- `value is nil`: result is nil
- Result is clamped to [0.0, 1.0]

## Grading UI

On the lesson ended/graded page:
- Two range sliders: min (lower threshold) and max (upper threshold), both ranging from 0 to the maximum points any student earned.
- Moving sliders **live-previews** calculated grades on each student's cell without saving.
- "Grade" button saves and triggers the full calculation chain.
- Re-grading an already-graded lesson shows a confirmation dialog.
