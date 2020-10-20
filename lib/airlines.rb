class Airlines
  attr_accessor :name, :flight_number
  @@all = []

  def initialize(airline)
    @name = airline
    @@all << self
  end

  def self.all
    @@all
  end

  def new_flight(flight_number)
    Flights.new(flight_number, self)
  end

  def flights
    flights = Flights.all.select {|flight| flight.airline == self}
  end

  def self.find_by_name(name)
    self.all.find {|airline| airline.name == name}
  end

  def self.find_or_create_by(name)
    if self.find_by_name(name) == nil 
      self.new(name)
    else
      self.find_by_name(name)
    end
  end
end 