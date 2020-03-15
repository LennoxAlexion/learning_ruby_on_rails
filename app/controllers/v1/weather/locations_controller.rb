class V1::Weather::LocationsController < ApplicationController
  require_relative './helper_methods/weather_helper'
  def index
    # TODO: remove index
    location = LocTemp.all

    render json: location, status: :ok
  end

  def show
    wh = V1::Weather::HelperMethods::WeatherHelper.new
    if validate_param
      render json: { message: wh.get_weather([params[:id].to_i], 1) }, status: :ok
    else
      render json: { message: 'Invalid location ' + params[:id] }, status: :ok
    end
  end

  private

  def validate_param
    # TODO: check if the location id is valid based on the json file by OW api
    params[:id].to_i.positive?
  end
end
