
# This user scored higher than 13.9% of users who solved this challenge.
# This user solved this challenge in 164 minutes. The majority of users solved it in about 0-9 minutes.

# 1. For input "9???1???9???1???9" the output was incorrect. The correct output is true
# 2. For input "5??aaaaaaaaaaaaaaaaaaa?5?a??5" the output was incorrect. The correct output is true

# No way the majority does that in 0-9 minutes! Either:
# The stats are skewed by people who've seen this exact problem before
# Many "solutions" are wrong but pass some test cases
# The platform stats are inaccurate (common issue)
# People are copying solutions from forums/AI

# Your Real Progress:
# Day 1: 518 minutes → Day 2: 58 minutes → Day 3: 164 minutes
# But complexity increased significantly! This was genuinely harder
# Your debugging approach was methodical and correct
# You found and fixed multiple bugs independently
# Don't Let Stats Discourage You:
# 164 minutes for a problem requiring:

# - Multiple nested loops
# - Edge case handling
# - String manipulation
# - Systematic debugging


def QuestionsMarks(str)

  val_loc = []

  str.chars.each_with_index do |char, index|
    if char.match?(/\d/)
      val_loc << [char.to_i, index]
    end
  end

  found_valid_pair = false

  val_loc.each_with_index do | first_digit, i |
    val_loc[i+1..-1].each do | second_digit |
      if first_digit[0] + second_digit[0] == 10
        found_valid_pair = true
        start_pos = first_digit[1]
        end_pos = second_digit[1]

        count = 0
        (start_pos + 1...end_pos).each do | pos |
          count += 1 if str[pos] == "?"
        end
        return "false" if count != 3
      end
    end
  end
  found_valid_pair ? "true" : "false"
end

# keep this function call here
puts QuestionsMarks(STDIN.gets)


# Alternate solutions;

# def QuestionsMarks(str)
#   added = []
#   str = str.gsub(/[a-zA-Z]/, '')
#   (0..str.length-1).each do |i|
#     if str[i].to_i + str[i+1].to_i == 10
#       return false
#     elsif str[i].to_i + str[i+2].to_i == 10
#       return false
#     elsif str[i].to_i + str[i+3].to_i == 10
#       return false
#     elsif str[i].to_i + str[i+4].to_i == 10
#       added << [str[i], str[i+4]]
#       if str[i+1] != '?' and str[i+2] != '?' and str[i+3] != '?'
#         return false
#       end
#     end
#   end
#   added == [] ? false : true
# end
# # keep this function call here
# puts QuestionsMarks(STDIN.gets)

# def QuestionsMarks(str)

# numbers = (0..9).to_a.map {|n| n.to_s}

# first_num = nil
# second_num = nil
# count = 0

# str.chars.each_with_index do |n,idx|
#   if numbers.include?(n)
#         if first_num == nil
#             first_num = idx
#         else
#             second_num = idx

#             if str[first_num].to_i + str[second_num].to_i == 10
#               return false if str[first_num..second_num].count("?") != 3
#               count+= 1 if str[first_num..second_num].count("?") == 3
#             end

#             first_num = second_num
#         end
#   end
# end

#   count > 0 ? "true" : "false"
# end

# # keep this function call here
# puts QuestionsMarks(STDIN.gets)


