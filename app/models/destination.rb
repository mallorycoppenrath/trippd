# == Schema Information
#
# Table name: destinations
#
#  id         :integer          not null, primary key
#  city       :string
#  state      :string
#  country    :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  continent  :string
#

class Destination < ActiveRecord::Base
  has_many :trip_destinations
  has_many :trips, through: :trip_destinations
  has_many :activities


  # def self.most_popular_destination
  #   mp = self.handles_tie_for_most_popular
  #   if mp.length == 1
  #     mp[0]
  #   else
  #     array = mp.map { |d| d }
  #     #returns an array
  #   end
  # end

  # def self.popular_destinations
  #   top_destinations = TripDestination.group(:destination_id).count
  #   top_destinations = top_destinations.keys.first(3)
  #   top_destinations.map! do |destination|
  #     Destination.find(destination)
  #   end
  # end

  def self.popular_destinations
    Destination.find(TripDestination.group(:destination_id).order('count_destination_id desc').count(:destination_id).keys).first(3)
  end


 def self.handles_tie_for_most_popular
  most_popular = TripDestination.group(:destination_id).count
  final = most_popular.map { |k, v| k if v == most_popular.values.max }
    final.compact.map do |id|
      Destination.find(id)
    end
  end

 def self.all_cities
    self.all.map do |destination|
      destination.city
    end
  end

  def self.total_trips_to_each_destination(array)
    array.map do |city|
    "#{city}: " + self.total_trips_to(city).to_s
    end
  end    

  def self.search(query)
    where('city LIKE ? OR country LIKE ?', "%#{query}%", "%#{query}%")
  end

  def self.total_trips_to(city)
    (self.joins(:trips).where("city = ?", city)).count
  end

  def self.order_by_city
    Destination.order(:city)
  end  

  def activities_restaurants
    Activity.joins(:categories).where(:categories =>{name: "Restaurants"}).where(:activities => {destination_id: self.id})
  end

  def activities_shopping
    Activity.joins(:categories).where(:categories =>{name: "Shopping"}).where(:activities => {destination_id: self.id})
  end

  def activities_spa_fitness
    Activity.joins(:categories).where(:categories =>{name: "Spa/Fitness"}).where(:activities => {destination_id: self.id})
  end

  def activities_music
    Activity.joins(:categories).where(:categories =>{name: "Music"}).where(:activities => {destination_id: self.id})
  end

  def activities_active
    Activity.joins(:categories).where(:categories =>{name: "Active"}).where(:activities => {destination_id: self.id})
  end


end
