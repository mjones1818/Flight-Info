
class Flights
  attr_accessor :airline, :flight_number
  @@all = []
  
  def initialize(flight_number, airline)
    @flight_number =flight_number
    @airline = airline
    @@all << self
  end

  def self.all
    @@all
  end

  def self.reset_all
    @@all.clear
  end

  def self.find_or_create_by(flight_number,airline)
    if self.find_flight(flight_number) == nil
      self.new(flight_number, airline)
    else
      self.find_flight(flight_number)
    end
  end

  def self.find_flight(number)
    self.all.find {|flight| flight.flight_number == number}
  end

  def self.add_flight_info(flight_number,data)                #takes in flight number and hash of all data whatever it is and makes accessors and values
    returned = self.find_flight(flight_number)
            #uses number to pull up instance of flight
    data.each do |key, value|
      returned.class.attr_accessor(key)                         # makes an accessor 
      returned.send(("#{key}="), value)                         # adds value to accessor
    end
    returned
  end

  def self.print_information(flight_number)
    returned =self.find_flight(flight_number) #gets instance 
    returned.instance_variables.map do |var|

      new_var = var.to_s[1..-1].split("_").map(&:capitalize).join(' ') # splits on "_", capitalizes and joins into readable string
      new_data = returned.instance_variable_get(var) # gets data
      if new_var == "Airline"  #airline is an instance of airline so you need to return the name
        new_data = returned.airline.name
      end
      puts "#{new_var} - #{new_data}" #prints data
      puts ""
      sleep(0.3) #spaces it out
    end
    
  end

  def self.make_flights(flights)  #takes in an array, distinguishes between private and airline flights. uses find or create by to make instances
    flights.each do |flight|
      if flight.match(/\D\d+\D+/)  #uses regex to match a private flight. N235ND \D is any non digit, \d is any digit, + any amount, \D non digits
        flight_number = flight
        airline = "Private "
      else
        flight_number = flight.scan(/\d/).join  #grabs only the digits out of an airlines info
        airline = flight.scan(/\D/).join.chomp(" flight ") # grabs the airline name and removes "flight"
      end
      new_airline = Airlines.find_or_create_by(airline)         #creates airline instance
      Flights.find_or_create_by(flight_number, new_airline)   
    
    end
  end
end