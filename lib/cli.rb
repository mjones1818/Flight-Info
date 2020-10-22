class Cli

  def run
    welcome
    menu
    #goodbye
  end

  def welcome
    puts ""
    puts "Hello! Welcome to flights"
    puts ""
  end
  
  def menu
    input = nil
    while input != "exit"
      #program intro

      #puts "Hello! Welcome to flights. What would you like to do?"
      puts "What would you like to do?"
      puts ""
      puts "1. Retrieve all flights over a specific location"
      puts "2. Retrieve flight activity by airport"
      puts ""
      puts "Type exit to end program"
      input = gets.chomp
      case input
      when "1"
        puts "Please enter a location"
        input = gets.chomp
        #scrape data
        Flights.reset_all
        first = Api.new
        first.get_flights_overhead(input)
        #first.make_flights(input)
        #show data (all flights or flights by airline)
        puts ''
        puts 'These are the flights currently over your location'
        Flights.all.each_with_index do |flight, index|
          puts "#{index+1}. #{flight.airline.name} flight #{flight.flight_number}"
        end

        show_flight_information
        
        #view_by_airline = Flights.all.count+1
        #puts ''
        #puts "#{view_by_airline}. VIEW BY AIRLINE"
        #puts ""
        ##ask for input
        #puts "Select a flight for more information. Or type airline to see flights by airline"
        #input = gets.chomp
        ##second scrape
        #if input.to_i.between?(1,Flights.all.count)
        #  second = Api.new
        #  selection_flight_number = Flights.all[input.to_i-1].flight_number
        #  selection_airline = Flights.all[input.to_i-1].airline.name.split(" ").join("+")
        #  second.flight_info(selection_flight_number,selection_airline)
        #  #return results
        #  Flights.print_information(selection_flight_number)
        #elsif input == "airline" || input.to_i == view_by_airline
        #  puts "Choose airline name"
        #    Airlines.all.each_with_index do |airline, index|
        #      puts "#{index+1}. #{airline.name}"
        #    end
        #  input = gets.chomp
        #  matching_airline = Airlines.find_by_name(Airlines.all[input.to_i-1].name)
        #  puts "#{matching_airline.name} Flights:"
        #  flight_by_airline_array = []
        #  matching_airline.flights.each_with_index do |flight, index| 
        #    puts "#{index+1}. #{flight.flight_number}"
        #    flight_by_airline_array << flight
        #  end
        #  puts "Select flight for more information"
        #  input = gets.chomp
        #  third = Api.new
        #  selection_flight_number = flight_by_airline_array[input.to_i-1].flight_number
        #  selection_airline = matching_airline.name
        #  third.flight_info(selection_flight_number,selection_airline)
        #  #return results
        #  Flights.print_information(selection_flight_number)
        #  
        #end
        when "2" 
        puts ""
        puts "Enter an airport code or city name"
        puts ""
        input = gets.chomp
        Flights.reset_all
        fourth = Api.new
        fourth.airport_activity(input)
        Flights.all.each_with_index do |flight, index|
          puts "#{index+1}. #{flight.airline.name} flight #{flight.flight_number}--------------------------#{flight.flight_summary}"
          #puts "------#{flight.flight_summary}"
        end
        show_flight_information
      end
    end
  end


  def show_flight_information
    view_by_airline = Flights.all.count+1
        puts ''
        puts "#{view_by_airline}. VIEW BY AIRLINE"
        puts ""
        #ask for input
        puts "Select a flight for more information. Or type airline to see flights by airline"
        input = gets.chomp
        #second scrape
        if input.to_i.between?(1,Flights.all.count)
          second = Api.new
          selection_flight_number = Flights.all[input.to_i-1].flight_number
          selection_airline = Flights.all[input.to_i-1].airline.name.split(" ").join("+")
          second.flight_info(selection_flight_number,selection_airline)
          #return results
          Flights.print_information(selection_flight_number)
        elsif input == "airline" || input.to_i == view_by_airline
          puts "Choose airline name"
            Airlines.all.each_with_index do |airline, index|
              puts "#{index+1}. #{airline.name}"
            end
          input = gets.chomp
          matching_airline = Airlines.find_by_name(Airlines.all[input.to_i-1].name)
          puts "#{matching_airline.name} Flights:"
          flight_by_airline_array = []
          matching_airline.flights.each_with_index do |flight, index| 
            puts "#{index+1}. #{flight.flight_number}"
            flight_by_airline_array << flight
          end
          puts "Select flight for more information"
          input = gets.chomp
          third = Api.new
          selection_flight_number = flight_by_airline_array[input.to_i-1].flight_number
          selection_airline = matching_airline.name
          third.flight_info(selection_flight_number,selection_airline)
          #return results
          Flights.print_information(selection_flight_number)
          
        end
  end
end