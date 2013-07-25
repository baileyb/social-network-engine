require 'spec_helper'

describe Post do


  before(:each) do
    @post = Post.new
    @post.assign_attributes({:text => "A test post"})
  end

  it 'can be created' do
    lambda {
      FactoryGirl.create(:post1)
    }.should change(Post, :count).by(1)
  end

  it "should not have a blank text" do
    @post.text = "   "
    @post.should_not be_valid
  end

  context "can filter posts" do
    it "created by organizations that current user is interested in" do
      current_user = FactoryGirl.create(:jason)
      posts = Post.Filter(current_user, 2, "0")
      posts.last.text.should == "Post by org3"
    end

    it "created by friends that current user is interested in" do
      current_user = FactoryGirl.create(:jason)
      posts = Post.Filter(current_user, 2, "0")
      posts.first.text.should == "Post by brian"
    end

  end

end
