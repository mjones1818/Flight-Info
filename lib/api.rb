class Api
  URL = "http://api.wolframalpha.com/v2/query?appid="
  APPID = "8P2YPV-XQVG699A8R"
  
  def get_flights_overhead(location)
    custom_url = "#{URL}#{APPID}&input=flights+seen+from+#{location}&podstate=Result__more&output=json"
    uri = URI.parse(custom_url)
    response = Net::HTTP.get_response(uri)
    flights = JSON.parse(response.body)
    all_flights =flights["queryresult"]["pods"][1]["subpods"][0]["img"]["alt"].split("|").drop(2)
    flight_results = all_flights.select {|item| item.include?("(")== false && item.include?("\n")}
    final = flight_results.map do |flight|
      
      if flight.split("\n")[1].strip == ""
        next
      else
        flight.split("\n")[1].strip
      end
    end
    final.delete(nil)
    make_flights(final.uniq)
    final.uniq
  end

  def make_flights(flights)
    flights.each do |flight|
      if flight.match(/\D\d+\D+/)
        flight_number = flight
        airline = "Private "
      else
        flight_number = flight.scan(/\d/).join
        airline = flight.scan(/\D/).join.chomp(" flight ")
      end
      new_airline = Airlines.find_or_create_by(airline)
      Flights.new(flight_number, new_airline)
    end
  end

  def flight_info(flight_number, airline)
    custom_url = "#{URL}#{APPID}&input=#{airline}+#{flight_number}&output=json"
    uri = URI.parse(custom_url)
    response = Net::HTTP.get_response(uri)
    flights = JSON.parse(response.body)
    flight_data = flights["queryresult"]["pods"][3]["subpods"][0]["img"]["alt"].split("\n")
    if flight_data.length < 2
      flight_data = flights["queryresult"]["pods"][2]["subpods"][0]["img"]["alt"].split("\n")
    end
    flight_info_hash = {}
    flight_data.each do |data|
      if data.include? "|"
        split = data.split(" | ")
        flight_info_hash[split[0].gsub(" ","_")] = split[1]
      else
        next
      end
    end
    Flights.add_flight_info(flight_number,flight_info_hash)    
  end

  def airport_activity(airport)
    if airport.split.size > 1
      airport = airport.gsub(" ","+")+"+airport"
    else
      airport = airport + "+airport"
    end
    custom_url = "#{URL}#{APPID}&input=#{airport}&includepodid=FlightsBetweenSummary:To:FlightData&podstate=5@FlightsBetweenSummary:To:FlightData__More&output=json&Scantimeout=20&parsetimeout=20&formattimeout=20&podtimeout=20"
    uri = URI.parse(custom_url)
    response = Net::HTTP.get_response(uri)
    flights = JSON.parse(response.body)
    #binding.pry
    arrived_flights = flights["queryresult"]["pods"][0]["subpods"][0]["img"]["alt"].split("\n")
    enroute_flights = flights["queryresult"]["pods"][0]["subpods"][1]["img"]["alt"].split("\n")
    scheduled_flights = flights["queryresult"]["pods"][0]["subpods"][2]["img"]["alt"].split("\n")
    arrived_flights_array = []
    enroute_flights_array = []
    scheduled_flights_array = []
    arrived_flights.each do |data|
      if data.include? "|"
        split = data.split(" | ")
        arrived_flights_array << split[0]
      else
        next
      end
    end

    enroute_flights.each do |data|
      if data.include? "|"
        split = data.split(" | ")
        enroute_flights_array << split[0]
      else
        next
      end
    end

    scheduled_flights.each do |data|
      if data.include? "|"
        split = data.split(" | ")
        arrived_flights_array << split[0]
      else
        next
      end
    end
    self.make_flights(arrived_flights_array)
    self.make_flights(enroute_flights_array)
    self.make_flights(arrived_flights_array)
  end 
end

# arrived_flights = flights["queryresult"]["pods"][0]["subpods"][0]["img"]["alt"]
# enroute_flights = flights["queryresult"]["pods"][1]["subpods"][0]["img"]["alt"]
# scheduled_flights = flights["queryresult"]["pods"][2]["subpods"][0]["img"]["alt"]

