class Cli

  def run
    welcome
    menu
    goodbye
  end

  def welcome
    puts ""
    puts "Welcome to flight info"
    puts ""
    sleep(1)
  end
  
  def menu
    input = nil
    while input != "exit"
      #program intro

      puts "What would you like to do?"
      puts ""
      puts "1. Retrieve all flights over a specific location"
      puts "2. Retrieve flight activity by airport"
      puts ""
      puts "Type exit to end program"
      input = gets.chomp
      case input
      when "1"
        puts "Please enter a location. You can use a city name or zip code"
        input = gets.chomp
        #scrape data
        Flights.reset_all
        first = Api.new
        first.get_flights_overhead(input)

        #show data (all flights or flights by airline)
        puts ''
        puts 'These are the flights currently over your location'
        Flights.all.each_with_index do |flight, index|
          puts "#{index+1}. #{flight.airline.name} flight #{flight.flight_number}"
        end
        @@flights_overhead = true
        show_flight_information
        
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
        end
        @@flights_overhead = false
        show_flight_information
      end
    end
  end


  def show_flight_information
    input = nil
    while input != "exit"
      view_by_airline = Flights.all.count+1
      puts ''
      puts "#{view_by_airline}. View by airline"
      puts ""

      #ask for input
      puts "Select a flight for more information or select view by airline. (unable to track private flights)"
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
        puts "Choose airline name. (unable to track private flights)"
          Airlines.all.each_with_index do |airline, index|
            puts "#{index+1}. #{airline.name}"
          end
        input = gets.chomp
        matching_airline = Airlines.find_by_name(Airlines.all[input.to_i-1].name)
        puts "#{matching_airline.name} Flights:"
        flight_by_airline_array = []
        if @@flights_overhead == false
          matching_airline.flights.each_with_index do |flight, index| 
            puts "#{index+1}. #{flight.flight_number}--------------------#{flight.flight_summary}"
            flight_by_airline_array << flight
          end
        else
          matching_airline.flights.each_with_index do |flight, index| 
            puts "#{index+1}. #{flight.flight_number}"
            flight_by_airline_array << flight
          end
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

      #sub_menu----------------------------
      puts "Please make a selection"
      puts "1. go back"
      puts "2. main menu"
      input = gets.chomp
      case input
      when "1"
        input = 'back'
        if @@flights_overhead == false
          Flights.all.each_with_index do |flight, index|
            puts "#{index+1}. #{flight.airline.name} flight #{flight.flight_number}--------------------------#{flight.flight_summary}"
            #puts "------#{flight.flight_summary}"
          end
        elsif @@flights_overhead == true
          Flights.all.each_with_index do |flight, index|
            puts "#{index+1}. #{flight.airline.name} flight #{flight.flight_number}"
          end
        end
      
      when "2"
        input = "exit"
      end
    end
  end

  def goodbye
    puts ""
    puts "Thanks for using flight info"
    puts ""
  end
end