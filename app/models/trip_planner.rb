=begin RDOC
  This model is used to find routes using the King County Metro Trip Planner.
  If the King County Metro Trip Planner changes this model will stop working since it relies on the current query format and html response format.
=end
class TripPlanner < ActiveRecord::Base
  self.abstract_class = true
  
  # returns an array of itinerary's with departure and arrival pairs for each itinerary
  # example: [trip_time, [ departure_itin1, arrival, departure, arrival ], [ itin2 ] ]
  def self.find_times(options = {}, trip_time = Time.now, routes = nil)
    routes = find_routes(options, trip_time) if routes.nil?
    times_array = []
    routes.each do |route|
      route_time_array = route.scan(/\<font size="-1"\>At (\d\d):(\d\d) (AM|PM)\<\/font\>/)
      route_times = []
      route_time_array.each do |time|
        hour = (time[0].to_i + 12).to_s if time[2] == "PM"
        route_times << Time.local(trip_time.strftime('%Y'), trip_time.strftime('%b'), 
                                trip_time.strftime('%d'), hour, time[1])
      end
      times_array << route_times
    end
    return [trip_time, times_array]
  end
  
  def self.find_trip_duration(options = {}, trip_time = Time.now, routes = nil)
    trip_time, times_array = find_times(options = {}, trip_time = Time.now, routes)
    trip_durations = []
    # subtract the final arrival time from the start time
    times_array.each do |times|
      seconds = times.last - times.first
      mins = 0
      if seconds >=  60 then
        mins = (seconds / 60).to_i
      end
      trip_durations << mins
    end
    return trip_durations
  end  
  
  # this uses the king county trip planner to find itinerarys to the passed address
  
  # right now it assumes that the origin will work on the first try
  # and that the destination is in Seattle
  def self.find_routes(options = {}, trip_time = Time.now)
    post_params = {
                    'Arr'=>'A', # 'D' for depart at 
                    'Min'=>'T',
                    'Date'=>trip_time.strftime('%m/%d/%y'),
                    'Dest'=>'3010 59th Ave SW'.upcase,
                    'Orig'=>'NE Campus Pkwy & 12th Ave NE'.upcase,
                    'Submit'=>'Plan Trip', 
                    'Time'=>'', 
                    'Walk'=>'1',
                    'action'=>'entry',
                    'ampm_time'=>trip_time.strftime('%p').downcase,
                    'destacode'=>'', 
                    'destloc'=>'', 
                    'destlocid'=>'0',
                    'destx'=>'', 
                    'desty'=>'',
                    'hour_time'=>trip_time.strftime('%I'),
                    'minute_time'=>trip_time.strftime('%M'),
                    'origacode'=>'', 
                    'origloc'=>'', 
                    'origlocid'=>'0',
                    'origx'=>'', 
                    'origy'=>'',
                    'resptype'=>'U'
                  } 
                  
    post_params = post_params.merge(options)
    
    result = Net::HTTP.post_form(URI.parse('http://tripplanner.kingcounty.gov/cgi-bin/itin.pl'), post_params) rescue nil
    
    # figure out what to do with the results
    if result.body.include? '<!-- Hide information about each location -->'
      # try and narrow then if the address was not specific enough 
      return find_routes(find_location_information(result))
    else
      # return the results or nil if something went wrong with the Net::HTTP call
      return result.nil? ? nil : parse_routes(result)
    end
  end
  
  # return an array of the itinerary results
  def self.parse_routes(result)
    itinerary_list = result.body.split('<!-- Begin Itinerary List -->')[1].split(
                      '<!-- End Itinerary List -->')[0].split(/\<!-- Begin Itinerary \d --\>/) rescue nil
    if itinerary_list.nil?
      return nil
    end
    itinerary_list.shift # Drop the first element that just has a new line char in it
    itinerary_list_small = []
    itinerary_list.each do |itinerary|
      itinerary_list_small << itinerary.split(/\<!-- End Itinerary \d --\>/)[0].gsub(/\<a.*?\>(.*?)\<\/a\>/,'\1')
    end
    return itinerary_list_small
  end
  
  # if the address didnt not work the first time try and find it to try again
  def self.find_location_information(result)
    # pull out information that is needed
    split_page = result.body.split('<!-- Hidden Form Information -->')[1].split(
                        '<!-- Hide information entered on original input page -->')
                        
    hidden_form_info = split_page[0].strip.gsub(' ', '').split(/\n/)
    
    split_page = split_page[1].split('<!-- Hide information about each location -->')
    
    hidden_form_info << split_page[0].strip.gsub(' ', '').split(/\n/)
    hidden_form_info = hidden_form_info.flatten
    
    split_page = split_page[1].split('<!-- Begin Table of locations -->')
    
    # find and pull out the proper destination
    destination_info = split_page[0].strip.gsub(' ', '').split(/\n/)
    
    # create new_params
    # first pull out all the params that were handed over
    new_params = {}
    hidden_form_info.each do |s|
      values = s.scan(/name="(.*)"value="(.*)"/)[0]
      new_params[values[0]] = values[1]
    end
    # next pull out the new params and find out what stop is in seattle
    found_location = false
    destination_info.each do |s|
      match_location = s.match(/name="acode(\d)"value="SEA"\>/)
      unless match_location.nil?
        found_location = true
        new_params['locations'] = match_location[1]
      end
      values = s.scan(/name="(.*)"value="(.*)"/)[0]
      new_params[values[0]] = values[1]
    end
    
    # return the parameters
    return new_params
  end
  
end