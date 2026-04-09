<!-- Phase 3 — Performance / Index / Query Thinking

Challenge: You have an attendance_records table:

```
CREATE TABLE attendance_records (
  id SERIAL PRIMARY KEY,
  student_id INTEGER NOT NULL,
  status TEXT NOT NULL,
  recorded_at TIMESTAMP NOT NULL
);
```

A report frequently runs this query:

```
SELECT *
FROM attendance_records
WHERE student_id = 42
  AND recorded_at >= '2026-01-01'
  AND recorded_at < '2026-02-01'
ORDER BY recorded_at DESC;
```

Your task:

Recommend an index for this query.
Explain why that index helps.
Explain why indexing only status would not be very helpful here.
What this tests
index reasoning
query access patterns
performance thinking
Bonus

Write the actual CREATE INDEX statement.
Try to produce:

- the SQL
- a 1–3 sentence explanation
- for Phase 3, the index statement plus reasoning -->

#========================================================================
