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
      flight_number = flight.scan(/\d/).join
      airline = flight.scan(/\D/).join.chomp(" flight ")
      
      Flights.new(flight_number, airline)
    end
  end
end