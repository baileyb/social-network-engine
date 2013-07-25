require 'rubygems'
require 'rake'

namespace :daily do
  desc "Updates the data synchronized from Facebook"
  task :update_facebook_data => :environment do
    puts "Updating the Facebook data for all users."
    num_success = 0
    num_failed = 0
    User.all().each do |user|
      # Don't fail if there is an error for a user's update
      begin
        # Get friends and organizations from Facebook
        # NOTE: friend object returned from Facebook has the form:
        #   { "name" : "<friend name>", "id" : "<friend Facebook id>"}
        @graph = Koala::Facebook::API.new(user.token)
        friend_ids = @graph.get_connections("me", "friends").map{
            |i| i["id"]}
        org_ids = @graph.get_connections("me", "accounts").map{
            |i| i["id"]}
        user.UpdateData(friend_ids, org_ids, @graph.get_picture("me"))

        num_success += 1
      rescue
        num_failed += 1
      end
    end    

    puts "Updated " + num_success.to_s + " users successfully"
    puts "Updates failed on " + num_failed.to_s + " users"
  end
end
