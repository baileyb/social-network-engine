require 'spec_helper'

describe Organization do

  before(:each) do
    @organization = Organization.new
  end
	
	it "should allow mass assignment of assignable attributes" do	
	  assignable_attributes = [:facebook_id, :name, :is_city]
	  assignable_attributes.each do |assignable_attribute|
			should allow_mass_assignment_of assignable_attribute
		end
	end
		
	it "should have and belong to many users" do 
		should have_and_belong_to_many(:users)
	end		
	
	it "should have and belong to many managers" do 
		should have_and_belong_to_many(:managers)
	end	

	it "should have many posts" do 
	  should have_many(:posts)
	end	
	
  describe "AllCities" do
    before(:each) do
      @org1 = FactoryGirl.create(:org1)
      @org2 = FactoryGirl.create(:org2)
      @org3 = FactoryGirl.create(:org3)
      @city1 = FactoryGirl.create(:city1)
			@city2 = FactoryGirl.create(:city2)
			@city3 = FactoryGirl.create(:city3)
    end

    it "should return all cities" do
		  Organization.AllCities.length.should equal(3)
    end
  end	
end 

