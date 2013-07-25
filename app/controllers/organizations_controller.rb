class OrganizationsController < ApplicationController
  before_filter :authenticate_user!
  def show	
		@organization = Organization.find(params[:id])
		@posts = @organization.posts.reverse
		@path = "../"
    respond_to do |format|
      format.html # show.html.erb
    end
  end
	
	# POST /followOrganization/?id=
  def add_organization
		organization = Organization.find(params[:id])
		if !current_user.organizations.include?(organization)	
			current_user.organizations << Organization.find(params[:id])
		end
		respond_to do |format|
      format.json { head :ok }
    end
  end
	
	# POST /removeOrganization/?id=
  def remove_organization
		organization = Organization.find(params[:id])
		if current_user.organizations.include?(organization)	
			current_user.organizations.delete(organization)
		end
		respond_to do |format|
      format.json { head :ok }
    end
  end	
	
	def followers
		@organization = Organization.find(params[:id])
		@path = "../"
		@feedItemId = "organizationFollowerFeedItemId"		
	end
	
	def posts
		@organization = Organization.find(params[:id])
		@posts = @organization.posts.reverse
		@path = "../"
	end
	
end
