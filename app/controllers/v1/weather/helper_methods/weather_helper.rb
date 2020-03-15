class V1::Weather::HelperMethods::WeatherHelper
  def get_weather(loc_ids, days)
    #Validation:
    # if days > 5 or days < 5
    #   return error
    # end

    weather_data = LocTemp.filter_by_location(loc_ids)
    loc_count_hash = weather_data.group(:loc_ids).count
    #Get all the locations id with count < days
    stale = (loc_count_hash.select {|key, value| key < days}).keys
    
    if stale
      # its convenient to retrieve fresh data from model as we can have maximum 5 records (1 location 5 temp or 5 location 1 temp each)
      call_external_api(stale)
      return LocTemp.filter_by_location(loc_ids)
    else
      return weather_data
    end
  end

  def call_external_api(loc_ids)
    
  end