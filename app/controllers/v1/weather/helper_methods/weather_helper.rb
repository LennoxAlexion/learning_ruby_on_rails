class V1::Weather::HelperMethods::WeatherHelper
  require_relative './open_weather_api_helper'

  def get_weather(loc_ids, days)
    # Validation:
    # if days > 5 or days < 5
    #   return error
    # end
    error = { error: 'Invalid location or external weather API down' }
    weather_data = LocTemp.filter_by_location(loc_ids).select('loc_id, temperature')
    init_loc_count = Hash[loc_ids.zip([0])]
    loc_count_hash = weather_data.each_with_object(Hash.new(0)) { |h1, h2| h2[h1[:loc_id]] += 1 }
    loc_count_hash = init_loc_count.merge(loc_count_hash)
    # Get all the locations id with count < days
    stale = (loc_count_hash.select { |_, value| value < days }).keys
    if stale.empty?
      weather_data[0, days]
    else
      # its convenient to retrieve fresh data from model as we can have maximum
      # 5 records (1 location 5 temp or 5 location 1 temp each)
      # otherwise needa mechanism to merge the newly retrieved data
      call_external_api(stale) ? LocTemp.filter_by_location(loc_ids) : error
    end
  end

  private

  # Retruns boolean
  def add_to_model(data)
    loc_temp = LocTemp.create(loc_id: data['loc_id'], temperature: data['temp'],
                   date: data['date'], time: data['time'])
    loc_temp.save
  end

  def call_external_api(loc_ids)
    failed_loc = []
    # Bulk locations not supported in free version
    # TODO: Change this, bulk insert to the model
    ow = V1::Weather::HelperMethods::OpenWeatherApiHelper.new
    loc_ids.each do |loc|
      response = ow.weather(loc)
      # TODO: Check if results are accurate by taking a mod by 8
      # any time of the day get weather once for every day
      # API 
      response.parsed_response['list'].each_with_index do |item, index|
        next unless (index % 8).zero?

        model_data = Hash['loc_id' => loc]
        model_data['temp'] = item['main']['temp']
        model_data['date'] = DateTime.parse(item['dt_txt']).to_date
        model_data['time'] = DateTime.parse(item['dt_txt']).to_time
        failed_loc.push(loc) unless add_to_model(model_data)
      end
      return failed_loc.empty? ? true : false
    end
  end
end
