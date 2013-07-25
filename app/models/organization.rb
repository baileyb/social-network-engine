class Organization < ActiveRecord::Base
  attr_accessible :facebook_id, :name, :is_city, :profile_pic

  # The users who are interested in this organization
  has_and_belongs_to_many :users

  # The users who can manage this organization
  has_and_belongs_to_many :managers, :class_name => "User", :foreign_key => "organization_id", :association_foreign_key => "user_id", :join_table => "organization_administrators"

  # Any posts made by the organization
  has_many :posts

  # Return all cities
  def self.AllCities
    Organization.find(:all, :conditions => ["is_city = ?", true])
  end
end
