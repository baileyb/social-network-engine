class StatusController < ApplicationController
  before_filter :authenticate_user!
  def index
    lat, lng = params[:latitude], params[:longitude]

    @status = current_user.status.nil? ? Status.new : current_user.status
    @statuses = Status.includes(:user).order("severity DESC").map do |status|
      status.clear = true if status.user.id == current_user.id
      status
    end
    if lat && lng && !lat.to_s.empty? && !lng.to_s.empty?
      @statuses = @statuses.sort_by do  |a|
        a.distance = Geocoder::Calculations.distance_between([a.latitude,a.longitude], [lat,lng])
        a.direction = Geocoder::Calculations.compass_point Geocoder::Calculations.bearing_between([lat, lng], [a.latitude,a.longitude])
        a.distance
      end
    end
    @path = "../"
  end

  def create
    @status = params[:status]

    unless current_user.status.nil?
      current_user.status.update_attributes(@status)
    else
      current_user.create_status(@status)
    end

    respond_to do |format|
      format.html {redirect_to status_path(:latitude => @status[:latitude], :longitude => @status[:longitude])}
    end
  end

  def destroy
  end
end
