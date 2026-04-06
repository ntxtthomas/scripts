# Most Frequent API Endpoint
# Pattern: Hash map / frequency counting
# Scenario
# You are analyzing application logs.
# You receive a list of API endpoints hit during the last hour.

logs = [
  "/users",
  "/orders",
  "/users",
  "/users",
  "/products",
  "/orders"
]

# Task
# Return the endpoint that appears most frequently.
# Expected result:

# "/users"


# THE WORK

def most_frequent_endpoint(logs)
  counts = Hash.new(0)

  logs.each do | endpoint |
    counts[endpoint] += 1
  end
  counts.max_by { | endpoint, count | count }[0]
end

p most_frequent_endpoint(logs)


# THE THOUGHT PROCESS; 

# STEP 1 - UNDERSTAND THE PROBLEM

# We're given an list of endpoints. We need to find the one that appears the most often.
# So really, the job is:
# - count how many times each endpoint appears
# - figure out which count is highest
# - return that endpoint

# STEP 2 - NOTICE THE PATTERN
# This is a very common pattern: 
# - hash map
# - frequency counting

# In Ruby, a hash is perfect for this. Why?

# Because a hash lets us store data like this:
# ```
# {
#   "/users" => 3,
#   "/orders" => 2,
#   "/products" => 1
# }
# ```

# STEP 3 - SOLVE IT FIRST BY HAND
# Before writing code, let’s pretend we are the computer. We start with this list:
# ```
# logs = [
#   "/users",
#   "/orders",
#   "/users",
#   "/users",
#   "/products",
#   "/orders"
# ]
# ```

# We go one item at a time.

# First item: "/users"

# We haven’t seen it before, so count becomes 1.
# ```
# { "/users" => 1 }
# ```
# Second item: "/orders"

# New endpoint, so count becomes 1.
# ```
# { "/users" => 1, "/orders" => 1 }
# ```
# Third item: "/users"

# We have seen it before, so increase count.
# ```
# { "/users" => 2, "/orders" => 1 }
# ```
# Fourth item: "/users"

# Increase again.
# ```
# { "/users" => 3, "/orders" => 1 }
# ```
# Fifth item: "/products"

# New endpoint.
# ```
# { "/users" => 3, "/orders" => 1, "/products" => 1 }
# ```
# Sixth item: "/orders"

# Increase count.
# ```
# { "/users" => 3, "/orders" => 2, "/products" => 1 }
# ```
# Now we look for the highest value.

# - "/users" => 3
# - "/orders" => 2
# - "/products" => 1

# The winner is: "/users"

# STEP 4: TURN THAT THINKING INTO CODE

# We need:
# the logs array
# a hash to store counts
# a loop through the array
# a way to find the highest count

# Part A: Store the logs where the method can use them
# Your current method doesn’t take any arguments, but the logs array is outside it.
# The cleanest solution is to pass logs into the method.

# Like this:
# ```
# def most_frequent_endpoint(logs)
# end
# ```
# Then call it with:
# `most_frequent_endpoint(logs)`

# That’s better because the method can work with any list, not just one hardcoded list.

# Part B: Create a frequency hash
# We want a hash where every endpoint starts at 0.
# Ruby gives us a clean way to do that:
# `counts = Hash.new(0)`

# That means if we ask for a key that doesn’t exist yet, Ruby gives us 0.

# Example:
# `counts["/users"] # => 0`

# Part C: Loop through the logs
# For each endpoint, increase its count by 1:
# ```
# logs.each do |endpoint|
#   counts[endpoint] += 1
# end
# ```

# Let’s pause here. If endpoint is "/users":
# `counts["/users"] += 1`

# If it was 0, it becomes 1.
# If it was 1, it becomes 2.
# If it was 2, it becomes 3.

# That is the heart of frequency counting.

# Part D: Find the most frequent one

# At the end, counts looks like this:
# ```
# {
#   "/users" => 3,
#   "/orders" => 2,
#   "/products" => 1
# }
# ```
# Now we want the pair with the biggest count. Ruby can do that with:
# `counts.max_by { |endpoint, count| count }`

# This returns:
# `["/users", 3]`

# But we only want the endpoint, not the count. So we take the first part:
# `counts.max_by { |endpoint, count| count }[0]`

# That gives:
# `"/users"`

# STEP 5: FINAL SOLUTION

# Here is the complete working code:
# ```
# logs = [
#   "/users",
#   "/orders",
#   "/users",
#   "/users",
#   "/products",
#   "/orders"
# ]

# def most_frequent_endpoint(logs)
#   counts = Hash.new(0)

#   logs.each do |endpoint|
#     counts[endpoint] += 1
#   end

#   counts.max_by { |endpoint, count| count }[0]
# end

# puts most_frequent_endpoint(logs)
# ```

# Output:
# `/users`

# Step 6: READ THE CODE LINE BY LINE

# This line creates the method:
# `def most_frequent_endpoint(logs)`

# It says: “make a method named most_frequent_endpoint and give it a list called logs.”

# This line creates the count hash:
# `counts = Hash.new(0)`

# It says: “make a hash where every missing key starts at 0.”

# This loop visits every endpoint:
# `logs.each do |endpoint|`

# So on each pass:

# first endpoint is "/users"
# then "/orders"
# then "/users"
# and so on

# This increments the count:
# `counts[endpoint] += 1`

# If endpoint is "/users", that means:
# `counts["/users"] += 1`

# This finds the biggest count:
# `counts.max_by { |endpoint, count| count }[0]`

# It says:
# - look at every key-value pair in the hash
# - compare them using the count
# - return the pair with the largest count
# - then take [0], which is the endpoint itself

# Step 10: WHAT TO SAY OUT LOUD IN AN INTERVIEW


# A clean explanation would sound like this:

# I’d use a hash to count how many times each endpoint appears.
# Then I’d iterate through the array once, incrementing the count for each endpoint.
# After that, I’d find the endpoint with the highest count and return it.
# This gives me O(n) time complexity and O(n) space complexity.

# That is a strong answer for a simple coding challenge. 💡

# Final answer:
# ```
# logs = [
#   "/users",
#   "/orders",
#   "/users",
#   "/users",
#   "/products",
#   "/orders"
# ]

# def most_frequent_endpoint(logs)
#   counts = Hash.new(0)

#   logs.each do |endpoint|
#     counts[endpoint] += 1
#   end

#   counts.max_by { |endpoint, count| count }[0]
# end

# puts most_frequent_endpoint(logs)
# ```

