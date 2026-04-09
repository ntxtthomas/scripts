<!-- Phase 1 — Core CRUD Querying

Challenge: You have a table called students:

```
CREATE TABLE students (
  id SERIAL PRIMARY KEY,
  first_name TEXT NOT NULL,
  last_name TEXT NOT NULL,
  grade_level INTEGER NOT NULL,
  enrolled_on DATE NOT NULL
);
```

Write a query to return:

first_name
last_name
grade_level

for all students in grade 10, ordered by last_name ascending.

What this tests
SELECT
WHERE
ORDER BY
Bonus

Write an INSERT statement to add a new 10th grade student.
Try to produce:
- the SQL
- a 1–3 sentence explanation
- for Phase 3, the index statement plus reasoning
-->

#========================================================================
