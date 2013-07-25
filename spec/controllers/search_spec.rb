require 'spec_helper'

describe SearchController , :type => :controller do

  before(:each) do
		@james = FactoryGirl.create(:james)
		sign_in @james
		@org1 = FactoryGirl.create(:org1)
    @org2 = FactoryGirl.create(:org2)
    @org3 = FactoryGirl.create(:org3)
    @city1 = FactoryGirl.create(:city1)
		@city2 = FactoryGirl.create(:city2)
		@city3 = FactoryGirl.create(:city3)
    @brian = FactoryGirl.create(:brian)
		@post1 = FactoryGirl.create(:post1)
  end
		
	#TODO: obviously need to add more complete tests, but this is a start
		
	it "should find a post" do 
	  get :search, :q => 'Test'
		assigns(:results).size.should == 1
	end
	
	it "should find an organization" do 
	  get :search, :q => 'C', :type => SearchResult::Type::ORGANIZATION
		assigns(:results).size.should == 3
	end
	
	it "should find a user" do 
	  get :search, :q => 'Brian', :type => SearchResult::Type::USER
		assigns(:results).size.should == 1
	end
	

end
