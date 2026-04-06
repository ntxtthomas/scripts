# Detect Duplicate User Emails
# Pattern: Hash map / set
# Scenario: You are importing users from multiple systems.

emails = [
  "alice@example.com",
  "bob@example.com",
  "alice@example.com",
  "carol@example.com"
]

def detect_dups_arr(emails)
  dups = emails.select { |e| emails.count(e) > 1 }
  dups.uniq
end

p detect_dups_arr(emails)

          ~.OR ~

def detect_dups_hash(emails)
  counts = emails.tally
  duplicates = counts.select { |value, count| count > 1 }.keys
end

p detect_dups_hash(emails)



# Task:
# Return all duplicate emails.
# Expected: ["alice@example.com"]

# ========================================================================

# - Understand the problem
# - Notice the pattern
# - Solve it by hand first
iterarate the array, find where count is > 1, push duplicate value to hash
# - Turn that thinking into code
# - Final solution
# - Read the code line by line
# - What the hash looks like during execution
# - Time and space complexity
# - A very beginner-friendly version
# - What to say out loud in an interview