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
    final.uniq
    

  end

  def make_flights(location)
    all_flights = get_flights_overhead(location)
    all_flights.each do |flight|
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
    custom_url = "#{URL}#{APPID}&input=#{airport}&includepodid=FlightsBetweenSummary:To:FlightData&podstate=FlightsBetweenSummary:To:FlightData__More&output=json"
    uri = URI.parse(custom_url)
    response = Net::HTTP.get_response(uri)
    flights = JSON.parse(response.body)
    binding.pry
  end 
end


#http://api.wolframalpha.com/v2/query?appid=8P2YPV-XQVG699A8R&input=ord+airport&includepodid=FlightsBetweenSummary:To:FlightData&output=json
# airline and flight number flights["queryresult"]["pods"][0]["subpods"][0]["img"]["alt"]
# plain text route - flights["queryresult"]["pods"][1]["subpods"][0]["img"]["alt"]
# dept airport - flights["queryresult"]["pods"][3]["subpods"][0]["img"]["alt"].split("\n")[0]
# sched take off - flights["queryresult"]["pods"][3]["subpods"][0]["img"]["alt"].split("\n")[1]
# arrival time - flights["queryresult"]["pods"][3]["subpods"][0]["img"]["alt"].split("\n")[2]
# scheduled landing - flights["queryresult"]["pods"][3]["subpods"][0]["img"]["alt"].split("\n")[3]
#estimates landing - flights["queryresult"]["pods"][3]["subpods"][0]["img"]["alt"].split("\n")[4]
#estimated_flight_duration = flights["queryresult"]["pods"][3]["subpods"][0]["img"]["alt"].split("\n")[5]
#time_since_takeoff = flights["queryresult"]["pods"][3]["subpods"][0]["img"]["alt"].split("\n")[6]


#light_info_hash = {
#     airline_and_flight_number:  flights["queryresult"]["pods"][0]["subpods"][0]["img"]["alt"],
#     plain_text_route: flights["queryresult"]["pods"][1]["subpods"][0]["img"]["alt"],
#     dept_airport: flights["queryresult"]["pods"][3]["subpods"][0]["img"]["alt"].split("\n")[0],
#     sched_take_off: flights["queryresult"]["pods"][3]["subpods"][0]["img"]["alt"].split("\n")[1],
#     arrival_time: flights["queryresult"]["pods"][3]["subpods"][0]["img"]["alt"].split("\n")[2],
#     scheduled_landing: flights["queryresult"]["pods"][3]["subpods"][0]["img"]["alt"].split("\n")[3],
#     estimated_landing: flights["queryresult"]["pods"][3]["subpods"][0]["img"]["alt"].split("\n")[4],
#     estimated_flight_duration: flights["queryresult"]["pods"][3]["subpods"][0]["img"]["alt"].split("\n")[5],
#     time_since_takeoff: flights["queryresult"]["pods"][3]["subpods"][0]["img"]["alt"].split("\n")[6]
#   }



