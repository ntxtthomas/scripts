<!-- Phase 2 — JOINs and Aggregation

Challenge: You have two tables:

```
CREATE TABLE caregivers (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL
);

CREATE TABLE students (
  id SERIAL PRIMARY KEY,
  caregiver_id INTEGER REFERENCES caregivers(id),
  first_name TEXT NOT NULL,
  last_name TEXT NOT NULL
);
```

Write a query that returns:

- caregiver name
- number of students assigned to that caregiver

Sort by student count descending.

What this tests
JOIN
COUNT
GROUP BY
ORDER BY
Bonus

Adjust the query so caregivers with zero students still appear.
Try to produce:

- the SQL
- a 1–3 sentence explanation
- for Phase 3, the index statement plus reasoning -->

#========================================================================
