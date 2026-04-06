# Longest Unique Substring
# Pattern: Sliding window
# Scenario: You're analyzing user behavior in a text field.
# Task: Find the longest substring without repeating characters.
# Example: "abcabcbb"
# Result: 3
# Because "abc" is the longest unique substring.

def longest_uniq_substr(str)
	current_sub_str = []
	max_sub_str = []

	str.each_char do | c |
		if current_sub_str.include?(c) 
			current_sub_str.slice!(0..current_sub_str.index(c))
		end
		
		current_sub_str << c

		if current_sub_str.length > max_sub_str.length
			max_sub_str = current_sub_str.dup
		end
	end

	max_sub_str.length
end

str1 = "abc1234def" #<= should be 10 as there are no repeated characters
str2 = "abcabcbb" #<= should be 3, "abc" 
str3 = "dddead" #<= edge case, should be 3, ""
str4 = "daddead" #<= should be 3, "dad"
longest_uniq_substr(str1)
longest_uniq_substr(str2)
longest_uniq_substr(str3)
longest_uniq_substr(str4)


# setup an empty container for current_substr.
# go through each character in a given string. 
# has the character appearred anywhere inside the current substring already?
# how long is the current unique substring? current substring length
# what is the longest one I've seen so far? maximum substring length
# 
# 

# ========================================================================

# - Understand the problem
# - Notice the pattern
# - Solve it by hand first
# - Turn that thinking into code
# - Final solution
# - Read the code line by line
# - What the hash looks like during execution
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
|  Problem	|    Pattern					|
--------------------------------------------|
|  1		|    hash map					|
|  2		|    set lookup					|
|  3		|    stack						|
|  4		|    sliding window				|
|  5		|    sorting + intervals		|
|  6		|    hash lookup				|
|  7		|    recursion					|
|  8		|    two pointers				|
|  9		|    frequency + sorting		|
|  10		|    set lookup					|
|-------------------------------------------|
# These patterns cover 80–90% of real coding screens.

# One More Very Important Tip
# When you finish solving a problem, ask:
# “What pattern was this?”
# Training your brain to recognize patterns quickly is the real goal.