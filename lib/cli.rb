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
      when "1"                        #flights over a location
        puts "Please enter a location. You can use a city name or zip code"
        input = gets.chomp
        #scrape data
        Flights.reset_all              #clears all data from @@all
        first = Api.new             
        first.get_flights_overhead(input)    #starts first scrape with location as input

        #show data (all flights or flights by airline)
        puts ''
        puts 'These are the flights currently over your location'
        Flights.all.each_with_index do |flight, index|
          puts "#{index+1}. #{flight.airline.name} flight #{flight.flight_number}"  #prints out number, airline and flight number
        end
        @@flights_overhead = true  #sets variable so that self.show_flight_information can print the right info based on what method is using it
        show_flight_information    # adds view by airline option. asks user input to start second scrape
        
      when "2"                      #flight activity for an airport
        puts ""
        puts "Enter an airport code or city name"
        puts ""
        input = gets.chomp
        Flights.reset_all          #clears out everything
        fourth = Api.new
        fourth.airport_activity(input)   #starts second scrape. takes an airport code or ciy as string. 
        Flights.all.each_with_index do |flight, index|  # returns all instances of flights and the summaries
          #formatting 
          total_characters = (index + 1).to_s.length + flight.airline.name.length + flight.flight_number.length  + 10
          lines_to_add = 60 - total_characters
          lines = "-" * lines_to_add
          puts "#{index+1}. #{flight.airline.name} flight #{flight.flight_number}#{lines}#{flight.flight_summary}"
        end
        @@flights_overhead = false  #sets menu variable so that show_information can display summaries
        show_flight_information
      end
    end
  end


  def show_flight_information
    input = nil
    while input != "exit"  #allows user to stay in program
      view_by_airline = Flights.all.count+1  #gets a number one above the total of all flights
      puts ''
      puts "#{view_by_airline}. View by airline"
      puts ""

      #ask for input
      puts "Select a flight for more information or select view by airline. (unable to track private flights)"
      input = gets.chomp
      
      #second scrape
      if input.to_i.between?(1,Flights.all.count) #if user chooses item from list
        second = Api.new
        selection_flight_number = Flights.all[input.to_i-1].flight_number #changes input to array index by subtracting one. 
        selection_airline = Flights.all[input.to_i-1].airline.name.split(" ").join("+") # gets airline makes it URL compatible
        second.flight_info(selection_flight_number,selection_airline) #takes a flight number and airline and adds all flight info to instance of flight
        
      #return results
        Flights.print_information(selection_flight_number)
      elsif input == "airline" || input.to_i == view_by_airline  #if user types airline or view by airline number
        puts "Choose airline name. (unable to track private flights)"
          Airlines.all.each_with_index do |airline, index| #prints all airlines
            puts "#{index+1}. #{airline.name}"
          end
        input = gets.chomp
        matching_airline = Airlines.find_by_name(Airlines.all[input.to_i-1].name) #returns instance of airline
        puts "#{matching_airline.name} Flights:"
        flight_by_airline_array = [] #creates array
        
        if @@flights_overhead == false #used to determine if flight summary should be displayed. only available from airport activity
          matching_airline.flights.each_with_index do |flight, index| 
            total_characters = (index + 1).to_s.length + flight.airline.name.length + flight.flight_number.length  + 4
            lines_to_add = 60 - total_characters
            lines = "-" * lines_to_add
            puts "#{index+1}. #{flight.flight_number}#{lines}#{flight.flight_summary}"
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
        third = Api.new  # new api
        selection_flight_number = flight_by_airline_array[input.to_i-1].flight_number
        selection_airline = matching_airline.name
        third.flight_info(selection_flight_number,selection_airline) #makes accessors and adds data to flight instances
        #return results
        Flights.print_information(selection_flight_number) # takes flight number and prints out all keys and values
        
      end

      #sub_menu----------------------------
      puts "Please make a selection"
      puts "1. go back"
      puts "2. main menu"
      input = gets.chomp
      case input
      when "1"
        #prints out based on what menu
        if @@flights_overhead == false
          Flights.all.each_with_index do |flight, index|
            total_characters = (index + 1).to_s.length + flight.airline.name.length + flight.flight_number.length  + 4
            lines_to_add = 60 - total_characters
            lines = "-" * lines_to_add
            puts "#{index+1}. #{flight.airline.name} flight #{flight.flight_number}#{lines}#{flight.flight_summary}"
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