class FacebookTabAppController < ApplicationController
  # Allows us to stub the API for tests
  @@koala_api = Koala::Facebook::API

  def signup
  end

  def load_account
    @user = current_user

    # Redirect users not signed in
    if @user.nil?
      redirect_to "/facebook_tab_app/signup"
    end

    # If the form has been filled in
    if not params[:user].nil?
      no_errors = @user.update_attributes(params[:user])

      if no_errors
        # Get friends and organizations from Facebook
        # NOTE: friend object returned from Facebook has the form:
        #   { "name" : "<friend name>", "id" : "<friend Facebook id>"}
        @graph = @@koala_api.new(@user.token)
        friend_ids = @graph.get_connections("me", "friends").map{
            |i| i["id"]}
        orgs = @graph.get_connections("me", "accounts")
        org_ids = orgs.map{
            |i| i["id"]}

        # Only look at organizations that we administer
        orgs.select!{|o| not o["perms"].find_index("ADMINISTER").nil?}

        # Add the user as an admin if he is not already
        my_orgs = @user.organizations_managed
        orgs.each do |org|
          if my_orgs.index{|o| o.facebook_id == org["id"]}.nil?
            org_object = Organization.find_by_facebook_id(org["id"])

            # Create the organization if it does not already exist.
            # Mark "Government organization"s as cities
            if org_object.nil?
              # Get org picture
              profile_pic_name = Util::save_picture(@graph.get_picture(orgs.first["id"]))
              org_object = Organization.create!(
                  :name => org["name"],
                  :facebook_id => org["id"],
                  :is_city => (org["category"] == "Government organization"),
                  :profile_pic => profile_pic_name)
            end

            # Make this user an admin in the organization
            org_object.managers << @user
          end
        end

        # Update friends, organizations, and profile picture
        @user.reload
        @user.UpdateData(friend_ids, org_ids, @graph.get_picture("me"))

        # If there are organizations, load those
        @organizations = @user.organizations_managed
        if not @organizations.empty?
          render 'load_organizations'
        else
          render 'done'
        end
      else
        render 'load_account'
      end
    end
  end

  def load_organizations
    # TODO: Look into the weird thing happening with authentication

    # We already have set the user as an admin on all Organizations so only
    # delete them from Organizations they do not want to be associated with.
    if not params[:orgs_num].nil?
      params.each do |param|
        key = param.first
        value = param.second

        # Delete the organization objects with value 0
        # (params form: "org_<organization ID>")
        if key.starts_with? "org_" and value == "0"
          org = Organization.find_by_id(key.split("_")[1].to_i)

          # Only delete the Organization if this user is the only admin
          if not org.nil? and org.managers.length == 1
            org.destroy
          end
        end
      end

      render 'done'
    else
      render 'load_organizations'
    end
  end

  def done
    @user = current_user

    # Redirect users not signed in
    if @user.nil?
      redirect_to "/facebook_tab_app/signup"
    end
  end
end
