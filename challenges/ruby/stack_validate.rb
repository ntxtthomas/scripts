# Validate Parentheses in a Query Filter
# Pattern: Stack
# Scenario
# Users can build complex filters like:
# (status:active AND (role:admin OR role:editor))

# You must verify the parentheses are valid.

# Task
# Return true or false.
# Examples:

# "(a AND (b OR c))" → true
# "(a AND (b OR c)" → false
# ")a(" → false

# ========================================================================

string1 = "(a AND (b OR c))"
string2 = "(a AND (b OR c)"
string3 = ")a("

def parenthesis_validation(str)
	stack = []

	str.each_char do | char |
		if char === '('
			stack << char
		elsif char === ')'
			return false if stack.empty?
			stack.pop
		end
	end

	stack.empty?
end

parenthesis_validation(string1)
parenthesis_validation(string2)
parenthesis_validation(string3)

# ========================================================================

this is specific to strings containing paranthesis. if the string value is an "(" there must me a matching ")" to be true, otherwise its false.
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