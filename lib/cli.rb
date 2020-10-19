class Cli

  def run
  #program intro
  puts "Hello! Welcome to flights. What is your location? Please enter a zip code"
  location = gets.chomp
  
  
  #scrape data
  first = Api.new
  first.make_flights(location)

  #show data (all flights or flights by airline)
   p Flights.all
  #ask for input

  #second scrape
  end

end