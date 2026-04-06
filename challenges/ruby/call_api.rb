require 'net/http'
require 'uri'
require 'json'

# Fetch wizard data from API
uri = URI('https://coderbyte.com/api/challenges/json/wizard-list')
response = Net::HTTP.get(uri)
data = JSON.parse(response)

# Filter out wizards with empty/nil houses
filtered_data = data.reject { |wizard| wizard["house"].nil? || wizard["house"].empty? }

# Group wizards by house
grouped = filtered_data.group_by { |wizard| wizard["house"] }

# Calculate average age for each house
result = grouped.map do |house, wizards|
  # Get ages, removing nils
  ages = wizards.map { |wizard| wizard["age"] }.compact

  # Calculate average and round to integer
  average_age = ages.sum / ages.length.to_f

  # Create result object
  {
    "house" => house,
    "average_age" => average_age.round
  }
end

# Output as JSON
puts result.to_json


