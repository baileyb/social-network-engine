class UsersController < ApplicationController
  before_filter :authenticate_user! 
  def show
		@user = User.find(params[:id])
		@posts = @user.posts.reverse

		@path = "../"
    respond_to do |format|
      format.html # show.html.erb
    end
  end
	
  # POST followUser/?id=
  def add_friend
		user = User.find(params[:id])
		if !current_user.friends.include?(user)	
			current_user.friends << User.find(params[:id])
		end
		respond_to do |format|
      format.json { head :ok }
    end
  end
	
	# POST removeUser/?id=
  def remove_friend
		user = User.find(params[:id])
		if current_user.friends.include?(user)	
			current_user.friends.delete(User.find(params[:id]))
		end
		respond_to do |format|
      format.json { head :ok }
    end
  end
	
	def followings
		@user = User.find(params[:id])
		@path = "../"
		@feedItemId = "followingFeedItemId"
	end
	
	def followers
		@user = User.find(params[:id])
		@path = "../"
		@feedItemId = "userFollowerFeedItemId"
	end
	
	def posts
		@user = User.find(params[:id])
		@posts = @user.posts.reverse
		@path = "../"
	end
	
	def organizations
		@user = User.find(params[:id])
		@path = "../"
		if(current_user == @user)
			@feedItemId = "followingFeedItemId"
		end
	end
end