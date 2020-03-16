class V1::Weather::SummaryController < ApplicationController
  def index
    wh = V1::Weather::HelperMethods::WeatherHelper.new
    correct_param
    if validate_param
      weather = wh.get_weather(params[:locations], 1, true, params[:unit])
      render json: { message: weather }, status: :ok
    else
      render json: { message: 'Invalid locations' }, status: :ok
    end
  end

  private

  def correct_param
    return if params[:locations].nil?

    params[:locations] = params[:locations].split(',').select { |num| num.to_i > 0 }.map(&:to_i)
    # default unit
    unless !params.fetch('unit', '').casecmp?('celsius') &&
           !params.fetch('unit', '').casecmp?('fahrenheit')
      return
    end

    params[:unit] = 'celsius'
  end

  def validate_param
    # TODO: check if the location id is valid based on the json file by OW api
    params[:locations].nil? ? false : params[:locations].length.positive?
  end
end
