# Merge Overlapping Booking Times
# Pattern: Sorting + intervals
# Scenario: You are building a scheduling tool.
# Meetings are stored as time ranges:[[1,3],[2,6],[8,10],[9,12]]
# Task: Merge overlapping intervals. Expected:[[1,6],[8,12]]

# ========================================================================

def sort_merge_booking_times(time_ranges)
  return [] if time_ranges.empty?

  time_ranges = time_ranges.sort! { |range| range[0]} #<= that mutates original data
  merged_intervals = [time_ranges.first] 

  time_ranges[1..-1].each do | time_range |
    last_merged_interval = merged_intervals.last
    
    if time_range[0] > last_merged_interval[1]
      merged_intervals.append(time_range)
    else 
      last_merged_interval[1] = [last_merged_interval[1], time_range[1]].max 
    end
  end

  merged_intervals
end

# time_ranges = [[2,6],[1,3],[8,10],[9,12]]
# sort_merge_booking_times(time_ranges)

# ========================================================================

# BEST PRACTICAL VERSION

def sort_merge_booking_times(time_ranges)
  return [] if time_ranges.empty?

  sorted_ranges = time_ranges.sort_by(&:first)
  merged = [sorted_ranges.first.dup] #<= the .dup protects original data

  sorted_ranges[1..].each do |current_start, current_end|
    if current_start > merged.last[1]
      merged << [current_start, current_end]
    else
      merged.last[1] = [merged.last[1], current_end].max
    end
  end

  merged
end

# ========================================================================

# - Understand the problem
# - Notice the pattern
# - Solve it by hand first
# - Turn that thinking into code
# - Final solution
# - Read the code line by line
# - What it looks like during execution
# - Time and space complexity
# - A very beginner-friendly version
# - What to say out loud in an interview


# A Very Simple Mental Cheat Sheet
# When you read a problem, ask:
# * Counting / duplicates? → hash map
# * Sorted / pair / both ends? → two pointers
# * Contiguous segment? → sliding window
# * Nested pairs / undo? → stack
# * Tree / graph / grid? → BFS or DFS
# * Overlaps / ordering? → sort first
# * All possibilities? → recursion/backtracking

# How to Practice These
# Step 1: Solve without a timer.
# Step 2: Refactor to the cleanest Ruby solution.
# Step 3: Redo later with 20-minute timer.
# This builds speed and clarity.

# What This Practice Set Trains
|-------------------------------------------|
|  Problem  |    Pattern                    |
--------------------------------------------|
|  1        |    hash map                   |
|  2        |    set lookup                 |
|  3        |    stack                      |
|  4        |    sliding window             |
|  5        |    sorting + intervals        |
|  6        |    hash lookup                |
|  7        |    recursion                  |
|  8        |    two pointers               |
|  9        |    frequency + sorting        |
|  10       |    set lookup                 |
|-------------------------------------------|
# These patterns cover 80–90% of real coding screens.

# One More Very Important Tip
# When you finish solving a problem, ask:
# “What pattern was this?”
# Training your brain to recognize patterns quickly is the real goal.