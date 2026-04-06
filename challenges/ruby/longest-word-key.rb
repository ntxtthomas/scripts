# My approach was to break it down in this way;
  # convert the string to an array
  # iterate through the array
  # compare the element lengths, saving the largest of them to a variable
  # return the largest element

# ✅ More explicit - easy to understand each step
# ✅ More debuggable - can add puts, trace logic
# ✅ Shows algorithmic thinking - demonstrates you can build solutions from scratch


def longest_string(str)
  # convert string to array and store in variable
  arr = str.split

  # keep track of the largest word seen
  largest = ""

  # Track the cleaned size separately
  largest_clean_size = 0

  arr.each do |element|
    clean_element = element.scan(/[a-zA-Z0-9]/).join
    if clean_element.size > largest_clean_size
      largest = element
      largest_clean_size = clean_element.size
    end
  end

  largest
end



# Their (the winner) approach:

# ✅ More concise - elegant one-liner
# ✅ Handles edge cases automatically - /\W+/ regex deals with all punctuation
# ✅ More functional - uses Ruby's built-in methods optimally

def LongestWord(sen)
  sen.split(/\W+/).max_by(&:length)
end