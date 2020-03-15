# require 'date'
# require 'httparty'
class V1::Weather::HelperMethods::OpenWeatherApiHelper
  include HTTParty
  base_uri 'api.openweathermap.org/'

  def weather(loc_id)
    # TODO: make these private
    api_key = 'e036a0a554b6751c3b3288348997f030'
    s_url = '/data/2.5/forecast?'
    s_id = 'id='
    s_appid = '&appid='
    s_unit = '&units=metric'

    # Default temperature unit is celcius
    self.class.get(s_url + s_id + loc_id.to_s + s_appid + api_key + s_unit)
  end
end
