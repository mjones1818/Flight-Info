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
    Flights.make_flights(final.uniq)
    final.uniq
  end

  def flight_info(flight_number, airline)
    custom_url = "#{URL}#{APPID}&input=#{airline}+#{flight_number}&output=json"
    uri = URI.parse(custom_url)
    response = Net::HTTP.get_response(uri)
    flights = JSON.parse(response.body)
    begin
      flight_data = flights["queryresult"]["pods"][2]["subpods"][0]["img"]["alt"].split("\n")
    rescue
      puts "Unable to retrieve flight information about this flight. Please start over"
      sleep(2)
      Cli.new.run
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
    flight_info_hash = {}
    arrived_flights.each do |data|
      if data.include? "|"
        split = data.split(" | ")
        arrived_flights_array << split[0]
        Flights.make_flights(arrived_flights_array)
        arrived_flights_array.clear
        flight_number = get_flight_number(split[0])
        flight_info_hash["flight_summary"] = split[1]
        Flights.add_flight_info(flight_number,flight_info_hash)
      else
        next
      end
    end
    
    enroute_flights.each do |data|
      if data.include? "|"
        split = data.split(" | ")
        enroute_flights_array << split[0]
        Flights.make_flights(enroute_flights_array)
        enroute_flights_array.clear
        flight_number = get_flight_number(split[0])
        flight_info_hash["flight_summary"] = split[1]
        Flights.add_flight_info(flight_number,flight_info_hash)
      else
        next
      end
    end

    scheduled_flights.each do |data|
      if data.include? "|"
        split = data.split(" | ")
        scheduled_flights_array << split[0]
        Flights.make_flights(scheduled_flights_array)
        scheduled_flights_array.clear
        flight_number = get_flight_number(split[0])
        flight_info_hash["flight_summary"] = split[1]
        Flights.add_flight_info(flight_number,flight_info_hash)
      else
        next
      end
    end
  end 

  def get_flight_number(flight)
    if flight.match(/\D\d+\D+/)
      flight_number = flight
      airline = "Private "
    else
      flight_number = flight.scan(/\d/).join
      airline = flight.scan(/\D/).join.chomp(" flight ")
    end
    flight_number

  end
end

