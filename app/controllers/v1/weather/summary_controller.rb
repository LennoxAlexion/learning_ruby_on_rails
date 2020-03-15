class V1::Weather::SummaryController < ApplicationController
  def index
    @locTemp = LocTemp.all

    render json: @locTemp, status: :ok
  end
end
