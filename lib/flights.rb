class Flights
  attr_accessor :airline, :flight_number
  @@all = []
  def initialize(flight_number, airline)
    @flight_number =flight_number
    @airline =airline
    @@all << self
  end

  def self.all
    @@all
  end
end