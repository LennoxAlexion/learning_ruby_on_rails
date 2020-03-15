class V1::Weather::LocationsController < ApplicationController
  def index
    location = LocTemp.all

    render json: location, status: :ok
  end

  def show
    User.find_each do |user|
      NewsMailer.weekly(user).deliver_now
    end
    LocTemp.find(params[:id])
  end

end
