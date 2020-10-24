class Api
  URL = "http://api.wolframalpha.com/v2/query?appid="
  APPID = "8P2YPV-XQVG699A8R"
  

  def get_flights_overhead(location)    #takes in a location. either a zip or city
    custom_url = "#{URL}#{APPID}&input=flights+seen+from+#{location}&podstate=Result__more&output=json"
    uri = URI.parse(custom_url)
    response = Net::HTTP.get_response(uri)
    flights = JSON.parse(response.body)  #returns everything in JSON
   
    begin                                #Error handling incase bad return
      all_flights =flights["queryresult"]["pods"][1]["subpods"][0]["img"]["alt"].split("|").drop(2)
    rescue
      puts "Unable to find flights from this location"
      sleep(2)
      Cli.new.run   #program restart 
    end
   
    flight_results = all_flights.select {|item| item.include?("(")== false && item.include?("\n")} #filter out extra info
    final = flight_results.map do |flight|
      if flight.split("\n")[1].strip == ""     # format flight results
        next
      else
        flight.split("\n")[1].strip
      end
    end
    final.delete(nil)                          #Delete Nil results
    Flights.make_flights(final.uniq)           #Send array of uniq flights to make an instance of each
    final.uniq                                 #return the array
  end

  def flight_info(flight_number, airline) #takes a flight number and airline and adds all flight info to instance of flight
    custom_url = "#{URL}#{APPID}&input=#{airline}+#{flight_number}&output=json"
    uri = URI.parse(custom_url)
    response = Net::HTTP.get_response(uri)
    flights = JSON.parse(response.body)
    binding.pry
    begin  #incase there is a bad response from the website the app will restart
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
        flight_info_hash[split[0].gsub(" ","_")] = split[1] #puts info into hash. airline key puts underscores between words
      else
        next
      end
    end
    Flights.add_flight_info(flight_number,flight_info_hash)    
  end

  def airport_activity(airport)  #takes in string of airport code or city
    if airport.split.size > 1    #if multi word string add "+" between words for the URL. add airport to both
      airport = airport.gsub(" ","+")+"+airport"
    else
      airport = airport + "+airport"
    end
    # URL is the base. APPID is my developer API key. Airport is string with + between. Includepod specifies which pod. shortens response
    #5@ pushes the "more" button 5 times to resturn all results. increase all the timeouts so it has time to return
    custom_url = "#{URL}#{APPID}&input=#{airport}&includepodid=FlightsBetweenSummary:To:FlightData&podstate=5@FlightsBetweenSummary:To:FlightData__More&output=json&Scantimeout=20&parsetimeout=20&formattimeout=20&podtimeout=20"
    uri = URI.parse(custom_url)
    response = Net::HTTP.get_response(uri)
    flights = JSON.parse(response.body)  #gets JSON body of response
    
    #returns in 3 different places in hash. puts the raw text in a variable 
    arrived_flights = flights["queryresult"]["pods"][0]["subpods"][0]["img"]["alt"].split("\n")
    enroute_flights = flights["queryresult"]["pods"][0]["subpods"][1]["img"]["alt"].split("\n")
    scheduled_flights = flights["queryresult"]["pods"][0]["subpods"][2]["img"]["alt"].split("\n")
    #creates arrays and a hash for all the info
    arrived_flights_array = []
    enroute_flights_array = []
    scheduled_flights_array = []
    flight_info_hash = {}
    
    #Parse out the data and create instances
    arrived_flights.each do |data|
      if data.include? "|"
        split = data.split(" | ") #split[0] is airline and flight number, split[1] is flight summary
        arrived_flights_array << split[0]
        Flights.make_flights(arrived_flights_array) #send airline and flight number array to make instance
        arrived_flights_array.clear #clear array for the next send. Make flight only designed to take one item in array
        flight_number = get_flight_number(split[0]) # uses regex to pull out flight number and return it
        flight_info_hash["flight_summary"] = split[1]
        Flights.add_flight_info(flight_number,flight_info_hash) #uses hash to create an attribute accessor with the key. value in this case is flight summary
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

