require 'spec_helper'

describe User do
  describe "model" do
    def valid_user_attributes
      { :email => 'TestUser@test.com', :password => 'testPassword'}
    end
  
    before(:each) do
      @user = User.new
    end
  
    it "should have an email" do
      @user.assign_attributes valid_user_attributes.except(:email)
      @user.should_not be_valid
      @user.email = valid_user_attributes[:email]
      @user.should be_valid
    end
	
    it "should have a password" do
      @user.assign_attributes valid_user_attributes.except(:password)
      @user.should_not be_valid
      @user.password = valid_user_attributes[:password]
      @user.should be_valid
    end
	
    it "should allow mass assignment of assignable attributes" do	
      assignable_attributes = [:name, :profile_pic, :email, :password, :password_confirmation, :remember_me, :token_expiration, :provider, :uid, :token]
      assignable_attributes.each do |assignable_attribute|
        should allow_mass_assignment_of assignable_attribute
      end
    end 
	
    it "should have many posts" do 
      should have_many(:posts)
    end
	
    it "should have and belong to many friends" do 
      should have_and_belong_to_many(:friends)
    end
	
    it "should have and belong to many managed organizations" do 
      should have_and_belong_to_many(:organizations_managed)
    end
	
    it "should have and belong to many organizations" do 
      should have_and_belong_to_many(:organizations)
    end
  end
	
  describe "UpdateFriends" do
    before(:each) do
      VCR.use_cassette 'model/user_update_friends' do
        @brian = FactoryGirl.create(:user5)
        @james = FactoryGirl.create(:james)
        @jason = FactoryGirl.create(:jason)
        @victor = FactoryGirl.create(:victor)
      end
    end

    it "should add Facebook friends with an SSN account to the user's friends" do
      @victor.UpdateFriends([@brian.uid, @james.uid])
      @victor.friends.length.should equal(2)
      @victor.friends.index{|f| f.id == @brian.id}.should_not be_nil
      @victor.friends.index{|f| f.id == @james.id}.should_not be_nil
      @victor.friends.index{|f| f.id == @jason.id}.should be_nil
    end

    it "should add Facebook friends with an SSN account and ignore those without an account" do
      @victor.UpdateFriends([@brian.uid, @james.uid, "101", "102"])
      @victor.friends.length.should equal(2)
      @victor.friends.index{|f| f.id == @brian.id}.should_not be_nil
      @victor.friends.index{|f| f.id == @james.id}.should_not be_nil
      @victor.friends.index{|f| f.id == @jason.id}.should be_nil
    end

    it "should not re-add Facebook friends that are already my friends" do
      @victor.friends << @brian
      @victor.UpdateFriends([@brian.uid, @james.uid])
      @victor.friends.length.should equal(2)
      @victor.friends.index{|f| f.id == @brian.id}.should_not be_nil
      @victor.friends.index{|f| f.id == @james.id}.should_not be_nil
      @victor.friends.index{|f| f.id == @jason.id}.should be_nil
    end

    it "should remove Facebook friends that I removed in Facebook" do
      @victor.friends << [@brian, @james]
      @victor.UpdateFriends([@brian.uid])
      @victor.friends.length.should equal(1)
      @victor.friends.index{|f| f.id == @brian.id}.should_not be_nil
      @victor.friends.index{|f| f.id == @james.id}.should be_nil
      @victor.friends.index{|f| f.id == @jason.id}.should be_nil
    end
  end
	
  describe "UpdateOrganizations" do
    before(:each) do
      VCR.use_cassette 'model/user_update_organizations' do
        @org1 = FactoryGirl.create(:org1)
        @org2 = FactoryGirl.create(:org2)
        @org3 = FactoryGirl.create(:org3)
        @victor = FactoryGirl.create(:victor)
      end
    end

    it "should add organizations with an SSN account to the user's orgnaizations" do
      @victor.UpdateOrganizations([@org1.facebook_id, @org2.facebook_id])
      @victor.organizations.length.should equal(2)
      @victor.organizations.index{|f| f.id == @org1.id}.should_not be_nil
      @victor.organizations.index{|f| f.id == @org2.id}.should_not be_nil
      @victor.organizations.index{|f| f.id == @org3.id}.should be_nil
    end

    it "should add Facebook organizations with an SSN account and ignore those without an account" do
      @victor.UpdateOrganizations([@org1.facebook_id, @org2.facebook_id, "101", "102"])
      @victor.organizations.length.should equal(2)
      @victor.organizations.index{|f| f.id == @org1.id}.should_not be_nil
      @victor.organizations.index{|f| f.id == @org2.id}.should_not be_nil
      @victor.organizations.index{|f| f.id == @org3.id}.should be_nil
    end

    it "should not re-add Facebook organizations that are already my organizations" do
      @victor.organizations << @org1
      @victor.UpdateOrganizations([@org1.facebook_id, @org2.facebook_id])
      @victor.organizations.length.should equal(2)
      @victor.organizations.index{|f| f.id == @org1.id}.should_not be_nil
      @victor.organizations.index{|f| f.id == @org2.id}.should_not be_nil
      @victor.organizations.index{|f| f.id == @org3.id}.should be_nil
    end

    it "should remove Facebook organizations that I removed in Facebook" do
      @victor.organizations << [@org1, @org2]
      @victor.UpdateOrganizations([@org1.facebook_id])
      @victor.organizations.length.should equal(1)
      @victor.organizations.index{|f| f.id == @org1.id}.should_not be_nil
      @victor.organizations.index{|f| f.id == @org2.id}.should be_nil
      @victor.organizations.index{|f| f.id == @org3.id}.should be_nil
    end
  end
end
