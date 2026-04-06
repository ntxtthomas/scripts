# FizzBuzz
#print numbers from 1 to 100,
# print "Fizz" for multiples of 3,
# "Buzz" for multiples of 5,
# and "FizzBuzz" for multiples of both 3 and 5

def fizz_buzz
  (1...100).each do | num |
    p "FIZZ! Number: #{num} is a multiple of 3" if num % 3 == 0
    p "BUZZ! Number: #{num} is a multiple of 5" if num % 5 == 0
    p "FIZZBUZZ! Number: #{num} is a multiple of 3 and 5" if num % 3 == 0 && num % 5 == 0
  end
end

# OR

def fizz_buzz
  (1..100).each do |num|
    if num % 3 == 0 && num % 5 == 0
      puts "FIZZBUZZ! Number: #{num} is a multiple of 3 and 5"
    elsif num % 3 == 0
      puts "FIZZ! Number: #{num} is a multiple of 3"
    elsif num % 5 == 0
      puts "BUZZ! Number: #{num} is a multiple of 5"
    else
      puts num
    end
  end
end

# OR

def fizz_buzz
  (1...100).each do | num |
    case
    when num % 3 == 0 && num % 5 == 0
      puts "FIZZBUZZ! Number: #{num} is a multiple of 3 and 5"
    when num % 3 == 0
      puts "FIZZ! Number: #{num} is a multiple of 3"
    when num % 5 == 0
      puts "BUZZ! Number: #{num} is a multiple of 5"
    else
      puts num
    end
  end
end

