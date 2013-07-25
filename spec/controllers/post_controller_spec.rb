require 'spec_helper'

describe PostsController do

  before(:each) do
    @jason = FactoryGirl.create(:jason)
    sign_in @jason
  end

  it "should return a list of posts" do
    get :index, :token => 0
    response.should render_template('index')
    (assigns(:posts).map{|p| p.text}).should match_array(["Post by brian", "Post by org3"])
  end


  it "should return a list of posts whose ids are greater than passed in token" do
    get :refresh, :token => 0
    (assigns(:posts).map{|p| p.text}).should match_array(["Post by brian", "Post by org3"])
  end

  it "should return nil with no post ids are greater than passed in token" do
    get :refresh, :token => 100
    assigns(:posts).size.should eq(0)
  end

  it "should be able to post as normal user" do
    lambda {
      post :create, :post => {:text=>"I am OK", :latitude=>-33.9417, :longitude=>150.9473}
    }.should change(Post, :count).by(1)
  end

  #it "should be able to post as an organization" do
  #  lambda {
  #    post :create, :post => {:text=>"I am OK", :latitude=>-33.9417, :longitude=>150.9473}
  #  }.should change(Post, :count).by(1)
  #end

end