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

  def self.add_flight_info(flight_number,data)
    returned = self.find_flight(flight_number)
    data.each do |key, value|
      returned.class.attr_accessor(key)
      returned.send(("#{key}="), value)
    end
    
    returned
  end

  def self.print_information(flight_number)
    returned =self.find_flight(flight_number)
    returned.instance_variables.map do |var|
      new_var = var.to_s[1..-1].split("_").map(&:capitalize).join(' ')
      new_data = returned.instance_variable_get(var)
      if new_var == "Airline"
        new_data = returned.airline.name
      end
      puts "#{new_var} - #{new_data}"
    end
    
  end

  def self.make_flights(flights)
    flights.each do |flight|
      if flight.match(/\D\d+\D+/)
        flight_number = flight
        airline = "Private "
      else
        flight_number = flight.scan(/\d/).join
        airline = flight.scan(/\D/).join.chomp(" flight ")
      end
      new_airline = Airlines.find_or_create_by(airline)
      Flights.find_or_create_by(flight_number, new_airline)
    end
  end
end