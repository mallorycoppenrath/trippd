# == Schema Information
#
# Table name: trips
#
#  id           :integer          not null, primary key
#  user_id      :integer
#  budget       :integer
#  start_date   :date
#  end_date     :date
#  total_guests :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  title        :string
#  range        :string
#

class TripsController < ApplicationController
  before_filter :authorize

  def index
    @trips = Trip.all
  end

  def new
    @trip = Trip.new
  end

  def create
    @trip = Trip.new(trip_params)
    if @trip.save 
      if @trip.destinations.any?
        @trip.destinations.first.destroy
      end
      current_user.current_trip_id = @trip.id
      current_user.save
      redirect_to @trip
    else
      render :new
    end
  end

  def show
    @trip = Trip.find(params[:id])
    @user = @trip.user
    @packing_lists = @trip.packing_lists.select{|packingList| packingList.name != nil}
    @packing_list = @trip.packing_lists.build
  end

  def edit
    @trip = Trip.find(params[:id])
  end

  def update
    @trip = Trip.find(params[:id])
    if @trip.update(trip_params)
      redirect_to @trip
    else
      render :edit
    end
  end

  def destroy
    @trip = Trip.find(params[:id])
    @user = User.find(session[:user_id]) 
    @user.current_trip_id = nil if @user.current_trip_id == @trip.id 
    @trip.destroy
    @user.reset_current_trip
    @user.save
    
    redirect_to trips_path
  end

 def send_email
    @trip = Trip.find(params[:id])
    @email = params[:email]
    @sender = params[:sender]
    ExampleMailer.trip_email(@email, @trip, @sender).deliver_now
    render json: {msg: "success!"}
  end

  private

  def trip_params
    params.require(:trip).permit(:budget, :title, :start_date, :end_date, :total_guests, :user_id)
  end


end
