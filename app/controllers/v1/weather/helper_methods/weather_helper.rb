class V1::Weather::HelperMethods::WeatherHelper
  require_relative './open_weather_api_helper'

  # loc_id-> [integers]; days-> int, just_next_day-> bool, unit -> string
  def get_weather(loc_ids, days, just_next_day, unit = CELSIUS)
    error = { error: 'Invalid location or external weather API down' }
    weather_data = LocTemp.filter_by_location(loc_ids, Date.today)
    result = build_response(weather_data, days, just_next_day, unit)
    # initialize location count
    loc_count_hash = Hash[loc_ids.product([0])]
    loc_count_hash = loc_count_hash.merge(result[1])
    # Get all the locations id with count < days
    stale = (loc_count_hash.select { |_, value| value < days }).keys
    unless stale.empty?
      # its convenient to retrieve fresh data from model as we can have maximum
      # 5 records (1 location 5 temp or 5 location 1 temp each)
      # otherwise need a mechanism to merge the newly retrieved data
      if call_external_api(stale)
        weather_data = LocTemp.filter_by_location(loc_ids, Date.today)
        result = build_response(weather_data, days, just_next_day, unit)
      else
        error
      end
    end
    result[0]
  end

  private

  CELSIUS = 'celsius'.freeze
  FAHRENHEIT = 'fahrenheit'.freeze
  private_constant :CELSIUS, :FAHRENHEIT

  def build_response(weather_data, days, just_next_day, unit)
    # TODO: add a check on date if we are picking correct date entries
    response = {}
    loc_count_hash = {}
    prev_day_temp = {}
    weather_data.each { |item|
      if loc_count_hash.fetch(item['loc_id'], 0) >= days ||
         (just_next_day && item['date'] == Date.today) ||
         (prev_day_temp.fetch(item['loc_id'], 0) == item['date'])
        next
      end

      temp = item['temperature'].to_f
      temp_unit = 'C'
      if unit.casecmp?(FAHRENHEIT)
        temp = (temp * 9 / 5) + 32
        temp_unit = 'F'
      end
      response[item['loc_id']] = response
                                 .fetch(item['loc_id'], [])
                                 .push({ 'temperature' => temp,
                                         'unit' => temp_unit,
                                         'date' => item['date'] })
      loc_count_hash[item['loc_id']] = loc_count_hash
                                       .fetch(item['loc_id'], 0) + 1
      prev_day_temp[item['loc_id']] = item['date']
    }
    [response, loc_count_hash]
  end

  def update_ext_api_counter
    counter = ExtApiCount.find_by(id: ExtApiCount.maximum(:id))
    if counter
      counter.update(count: counter.count + 1)
    else
      counter = ExtApiCount.create(count: 1)
    end
    counter.save
  end

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
      update_ext_api_counter
      # TODO: Check if results are accurate by taking a mod by 8 or use date instead
      # any time of the day get weather once for every day
      # Also check if we have a proper response
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
