require 'spec_helper'

describe FacebookTabAppController do
  render_views

  describe "signup" do
    describe "if not signed in" do
      it "should be successful" do
        get :signup
        response.should be_success
      end

      it "should display the signup page" do
        get :signup
        response.should render_template('signup')
      end
    end

    describe "if signed in" do
      before(:each) do
        @user = FactoryGirl.create(:victor)
        sign_in @user
      end

      it "should be successful" do
        get :signup
        response.should be_success
      end

      it "should display the signup page" do
        get :signup
        response.should render_template('signup')
      end
    end
  end

  describe "load_account" do
    describe "if not signed in" do
      it "should not be successful" do
        get :load_account
        response.should_not be_success
      end

      it "should forward to the signup page" do
        get :load_account
        response.should redirect_to('/facebook_tab_app/signup')
      end
    end

    describe "if signed in" do
      class MockKoalaApi
        @@friends = []
        @@accounts = []

        def initialize(token)
        end

        def get_connections(person, type)
          if person != "me"
            raise "Unexpected person '" + person.to_s + "' in get_connections"
          end

          if type == "friends"
            @@friends
          elsif type == "accounts"
            @@accounts
          else
            raise "Unexpected type '" + type.to_s + "' in get_connections"
          end
        end

        def get_picture(pic)

        end
      end

      before(:each) do
        @user = FactoryGirl.create(:victor)
        @friend1 = FactoryGirl.create(:user5)
        @friend2 = FactoryGirl.create(:james)
        @org1 = FactoryGirl.build(:org1)
        @org2 = FactoryGirl.build(:org2)
        @city1 = FactoryGirl.build(:city1)
        @city2 = FactoryGirl.build(:city2)
        sign_in @user

        # Stub out the Koala API
        FacebookTabAppController.class_variable_set :@@koala_api, MockKoalaApi
      end

      def set_friends(friends)
        MockKoalaApi.class_variable_set :@@friends, friends
      end

      def set_accounts(accounts)
        MockKoalaApi.class_variable_set :@@accounts, accounts
      end

      it "if no user param specified should render the page" do
        get :load_account
        response.should render_template('load_account')
      end

      it "user specified attributes should be updated" do
        set_friends([])
        set_accounts([])
        post :load_account, :user => {:name => "Bob Smith"}
        response.should be_success
        @user.reload
        @user.name.should eq("Bob Smith")
      end

      it "if there were error updating user information, should load those" do
        set_friends([])
        set_accounts([])
        post :load_account, :user => {:name => {}}
        response.should render_template('done')
      end

      it "should set friends" do
        unsaved_friend = FactoryGirl.build(:jason)
        set_friends([{"id" =>  @friend1.uid }, {"id" => @friend2.uid },
            {"id" => unsaved_friend.uid}])
        set_accounts([])
        post :load_account, :user => {:name => @user.name}
        @user.friends.length.should eq(2)
        @user.friends.index{|f| f.uid == @friend1.uid}.should_not be_nil
        @user.friends.index{|f| f.uid == @friend2.uid}.should_not be_nil
      end

      it "should not readd a friend" do
        set_friends([{"id" =>  @friend1.uid }, {"id" => @friend2.uid }])
        set_accounts([])
        @user.friends << @friend1
        @user.friends.length.should eq(1)
        post :load_account, :user => {:name => @user.name}
        @user.reload
        @user.friends.length.should eq(2)
        @user.friends.index{|f| f.uid == @friend1.uid}.should_not be_nil
        @user.friends.index{|f| f.uid == @friend2.uid}.should_not be_nil
      end

      it "should create groups I administer if they don't exist" do
        set_friends([])
        set_accounts([
            {"perms" => ["ADMINISTER"], "id" => @org1.facebook_id, "name" => @org1.name, "category" => "Team"},
            {"perms" => ["MEMBER", "ADMINISTER"], "id" => @org2.facebook_id, "name" => @org2.name, "category" => "Team"}])
        lambda do
          post :load_account, :user => {:name => @user.name}
        end.should change(Organization, :count).by(2)
        @user.organizations_managed.length.should eq(2)
        @user.organizations_managed.index{|o| o.facebook_id == @org1.facebook_id}.should_not be_nil
        @user.organizations_managed.index{|o| o.facebook_id == @org2.facebook_id}.should_not be_nil
        @user.organizations_managed[0].is_city.should eq(false)
        @user.organizations_managed[1].is_city.should eq(false)
      end

      it "should not create groups I administer if they exist" do
        set_friends([])
        set_accounts([
            {"perms" => ["ADMINISTER"], "id" => @org1.facebook_id, "name" => @org1.name, "category" => "Team"},
            {"perms" => ["MEMBER", "ADMINISTER"], "id" => @org2.facebook_id, "name" => @org2.name, "category" => "Team"}])
        @org1.save!
        @org2.save!
        lambda do
          post :load_account, :user => {:name => @user.name}
        end.should_not change(Organization, :count)
        @user.organizations_managed.length.should eq(2)
        @user.organizations_managed.index{|o| o.facebook_id == @org1.facebook_id}.should_not be_nil
        @user.organizations_managed.index{|o| o.facebook_id == @org2.facebook_id}.should_not be_nil
        @user.organizations_managed[0].is_city.should eq(false)
        @user.organizations_managed[1].is_city.should eq(false)
      end

      it "should not create groups if I don't administer them" do
        set_friends([])
        set_accounts([
            {"perms" => ["MEMBER"], "id" => @org1.facebook_id, "name" => @org1.name, "category" => "Team"},
            {"perms" => ["MEMBER"], "id" => @org2.facebook_id, "name" => @org2.name, "category" => "Team"}])
        lambda do
          post :load_account, :user => {:name => @user.name}
        end.should_not change(Organization, :count)
        @user.organizations_managed.length.should eq(0)
      end

      it "should not readd me to an organization I manage" do
        set_friends([])
        set_accounts([
            {"perms" => ["ADMINISTER"], "id" => @org1.facebook_id, "name" => @org1.name, "category" => "Team"},
            {"perms" => ["MEMBER", "ADMINISTER"], "id" => @org2.facebook_id, "name" => @org2.name, "category" => "Team"}])

        @org1.save!
        @user.organizations_managed << @org1

        lambda do
          post :load_account, :user => {:name => @user.name}
        end.should change(Organization, :count).by(1)
        @user.reload
        @user.organizations_managed.length.should eq(2)
        @user.organizations_managed.index{|o| o.facebook_id == @org1.facebook_id}.should_not be_nil
        @user.organizations_managed.index{|o| o.facebook_id == @org2.facebook_id}.should_not be_nil
      end

      it "should not readd me to a city I manage" do
        set_friends([])
        set_accounts([
            {"perms" => ["ADMINISTER"], "id" => @city1.facebook_id, "name" => @city1.name, "category" => "Government organization"},
            {"perms" => ["ADMINISTER"], "id" => @city2.facebook_id, "name" => @city2.name, "category" => "Government organization"}])

        @city1.save!
        @user.organizations_managed << @city1
        @user.organizations_managed.length.should eq(1)

        lambda do
          post :load_account, :user => {:name => @user.name}
        end.should change(Organization, :count).by(1)
        @user.reload
        @user.organizations_managed.length.should eq(2)
        @user.organizations_managed.index{|o| o.facebook_id == @city1.facebook_id}.should_not be_nil
        @user.organizations_managed.index{|o| o.facebook_id == @city2.facebook_id}.should_not be_nil
      end

      it "should make me interested in the organization and cities I manage" do
        set_friends([])
        set_accounts([
            {"perms" => ["ADMINISTER"], "id" => @org1.facebook_id, "name" => @org1.name, "category" => "Team"},
            {"perms" => ["MEMBER", "ADMINISTER"], "id" => @city1.facebook_id, "name" => @city1.name, "category" => "Government organization"}])
        lambda do
          post :load_account, :user => {:name => @user.name}
        end.should change(Organization, :count).by(2)
        @user.organizations_managed.length.should eq(2)
        @user.organizations_managed.index{|o| o.facebook_id == @org1.facebook_id}.should_not be_nil
        @user.organizations_managed.index{|o| o.facebook_id == @city1.facebook_id}.should_not be_nil
        @user.organizations.length.should eq(2)
        @user.organizations.index{|o| o.facebook_id == @org1.facebook_id}.should_not be_nil
        @user.organizations.index{|o| o.facebook_id == @city1.facebook_id}.should_not be_nil

        @user.organizations_managed[0].users.length.should eq(1)
        @user.organizations_managed[0].users[0].id.should eq(@user.id)
        @user.organizations_managed[1].users.length.should eq(1)
        @user.organizations_managed[1].users[0].id.should eq(@user.id)
      end

      it "if no organizations or cities are managed it should load done" do
        set_friends([])
        set_accounts([])
        post :load_account, :user => {:name => @user.name}
        response.should render_template("done")
      end

      it "if organization are managed it should load load_organizations" do
        set_friends([])
        set_accounts([
            {"perms" => ["ADMINISTER"], "id" => @org1.facebook_id, "name" => @org1.name, "category" => "Team"},
            {"perms" => ["MEMBER", "ADMINISTER"], "id" => @org2.facebook_id, "name" => @org2.name, "category" => "Team"}])
        post :load_account, :user => {:name => @user.name}
        response.should render_template("load_organizations")
      end

      it "if organization are managed and not created it should load load_organizations" do
        set_friends([])
        set_accounts([
            {"perms" => ["ADMINISTER"], "id" => @org1.facebook_id, "name" => @org1.name, "category" => "Team"},
            {"perms" => ["MEMBER", "ADMINISTER"], "id" => @org2.facebook_id, "name" => @org2.name, "category" => "Team"}])

        @org1.save!
        @org2.save!

        lambda do
          post :load_account, :user => {:name => @user.name}
        end.should_not change(Organization, :count)
        response.should render_template("load_organizations")
      end

      it "if cities are managed it should load load_organizations" do
        set_friends([])
        set_accounts([
            {"perms" => ["ADMINISTER"], "id" => @city1.facebook_id, "name" => @city1.name, "category" => "Government organization"},
            {"perms" => ["ADMINISTER"], "id" => @city2.facebook_id, "name" => @city2.name, "category" => "Government organization"}])
        post :load_account, :user => {:name => @user.name}
        response.should render_template("load_organizations")
      end

      it "if cities are managed and not created it should load load_organizations" do
        set_friends([])
        set_accounts([
            {"perms" => ["ADMINISTER"], "id" => @city1.facebook_id, "name" => @city1.name, "category" => "Government organization"},
            {"perms" => ["ADMINISTER"], "id" => @city2.facebook_id, "name" => @city2.name, "category" => "Government organization"}])

        @city1.save!
        @city2.save!

        lambda do
          post :load_account, :user => {:name => @user.name}
        end.should_not change(Organization, :count)
        response.should render_template("load_organizations")
      end

      it "should not create cities I administer and exist" do
        set_friends([])
        set_accounts([
            {"perms" => ["ADMINISTER"], "id" => @city1.facebook_id, "name" => @city1.name, "category" => "Government organization"},
            {"perms" => ["ADMINISTER"], "id" => @city2.facebook_id, "name" => @city2.name, "category" => "Government organization"}])

        @city1.save!
        @city2.save!
        lambda do
          post :load_account, :user => {:name => @user.name}
        end.should_not change(Organization, :count)
      end

      it "should not create cities I don't administer" do
        set_friends([])
        set_accounts([
            {"perms" => ["MEMBER"], "id" => @city1.facebook_id, "name" => @city1.name, "category" => "Government organization"},
            {"perms" => ["MEMBER"], "id" => @city2.facebook_id, "name" => @city2.name, "category" => "Government organization"}])
        lambda do
          post :load_account, :user => {:name => @user.name}
        end.should_not change(Organization, :count)
      end

      it "should create cities I administer and don't exist" do
        set_friends([])
        set_accounts([
            {"perms" => ["ADMINISTER"], "id" => @city1.facebook_id, "name" => @city1.name, "category" => "Government organization"},
            {"perms" => ["ADMINISTER"], "id" => @city2.facebook_id, "name" => @city2.name, "category" => "Government organization"}])
        lambda do
          post :load_account, :user => {:name => @user.name}
        end.should change(Organization, :count).by(2)

        @user.organizations_managed.length.should eq(2)
        @user.organizations_managed.index{|o| o.facebook_id == @city1.facebook_id}.should_not be_nil
        @user.organizations_managed.index{|o| o.facebook_id == @city2.facebook_id}.should_not be_nil
        @user.organizations_managed[0].is_city.should eq(true)
        @user.organizations_managed[1].is_city.should eq(true)
      end

      it "should set friends, groups, and cities I belong to" do
        set_friends([{"id" =>  @friend1.uid }, {"id" => @friend2.uid }])
        set_accounts([
            {"perms" => ["ADMINISTER"], "id" => @org1.facebook_id, "name" => @org1.name, "category" => "Team"},
            {"perms" => ["ADMINISTER"], "id" => @city1.facebook_id, "name" => @city1.name, "category" => "Government organization"}])
        post :load_account, :user => {:name => @user.name}

        @user.friends.length.should eq(2)
        @user.friends.index{|f| f.uid == @friend1.uid}.should_not be_nil
        @user.friends.index{|f| f.uid == @friend2.uid}.should_not be_nil

        @user.organizations_managed.length.should eq(2)
        @user.organizations_managed.index{|o| o.facebook_id == @org1.facebook_id}.should_not be_nil
        @user.organizations_managed.index{|o| o.facebook_id == @city1.facebook_id}.should_not be_nil
      end
    end
  end

  describe "load_organizations" do
    before(:each) do
      @user = FactoryGirl.create(:victor)
      @org1 = FactoryGirl.create(:org1)
      @org2 = FactoryGirl.create(:org2)
      @city1 = FactoryGirl.create(:city1)
      @city2 = FactoryGirl.create(:city2)

      @org1.save!
      @org2.save!
      @city1.save!
      @city2.save!

      @org1.managers << @user
      @org2.managers << @user
      @city1.managers << @user
      @city2.managers << @user
    end

    it "should be successful" do
      get :load_organizations
      response.should be_success
    end

    it "should display the load organizations page" do
      get :load_organizations
      response.should render_template('load_organizations')
    end

    it "should render the done page" do
      post :load_organizations, :orgs_num => 0
      response.should render_template('done')
    end

    it "should delete organization with value == 0" do
      org1_id = "org_" + @org1.id.to_s
      org2_id = "org_" + @org2.id.to_s
      lambda do
        post :load_organizations, :orgs_num => 2, org1_id => 0, org2_id => 0
        response.should render_template('done')
      end.should change(Organization, :count).by(-2)
    end

    it "should delete cities with value == 0" do
      org1_id = "org_" + @city1.id.to_s
      org2_id = "org_" + @city2.id.to_s
      lambda do
        post :load_organizations, :orgs_num => 2, org1_id => 0, org2_id => 0
        response.should render_template('done')
      end.should change(Organization, :count).by(-2)
    end

    it "should not delete organization with value == 1" do
      org1_id = "org_" + @org1.id.to_s
      org2_id = "org_" + @org2.id.to_s
      lambda do
        post :load_organizations, :orgs_num => 2, org1_id => 1, org2_id => 1
        response.should render_template('done')
      end.should_not change(Organization, :count)
    end

    it "should not delete cities with value == 1" do
      org1_id = "org_" + @city1.id.to_s
      org2_id = "org_" + @city2.id.to_s
      lambda do
        post :load_organizations, :orgs_num => 2, org1_id => 1, org2_id => 1
        response.should render_template('done')
      end.should_not change(Organization, :count)
    end

    it "should not delete organizations with more than 1 manager even if value == 0" do
      @user2 = FactoryGirl.create(:brian)
      @org1.managers << @user2
      @org2.managers << @user2
      org1_id = "org_" + @org1.id.to_s
      org2_id = "org_" + @org2.id.to_s
      lambda do
        post :load_organizations, :orgs_num => 2, org1_id => 0, org2_id => 0
        response.should render_template('done')
      end.should_not change(Organization, :count)
    end

    it "should not delete cities with more than 1 manager even if value == 0" do
      @user2 = FactoryGirl.create(:brian)
      @city1.managers << @user2
      @city2.managers << @user2
      org1_id = "org_" + @city1.id.to_s
      org2_id = "org_" + @city2.id.to_s
      lambda do
        post :load_organizations, :orgs_num => 2, org1_id => 0, org2_id => 0
        response.should render_template('done')
      end.should_not change(Organization, :count)
    end

    it "should only delete organizations/cities with value == 0 and leave those with value == 1" do
      org1_id = "org_" + @org1.id.to_s
      org2_id = "org_" + @org2.id.to_s
      org3_id = "org_" + @city1.id.to_s
      org4_id = "org_" + @city2.id.to_s
      lambda do
        post :load_organizations, :orgs_num => 2, org1_id => 0, org2_id => 1, org3_id => 0, org4_id => 1
        response.should render_template('done')
      end.should change(Organization, :count).by(-2)
      Organization.find_by_id(@org1.id).should be_nil
      Organization.find_by_id(@org2.id).should_not be_nil
      Organization.find_by_id(@city1.id).should be_nil
      Organization.find_by_id(@city2.id).should_not be_nil
    end
  end

  describe "done" do
    describe "if not signed in" do
      it "should not be successful" do
        get :done
        response.should_not be_success
      end

      it "should not display the page if the user is not signed in" do
        get :done
        response.should_not render_template('done')
      end

      it "should redirect the user to root" do
        get :done
        response.should_not redirect_to(root_path)
      end
    end

    describe "if signed in" do
      before(:each) do
        @user = FactoryGirl.create(:victor)
        sign_in @user
      end

      it "should be successful" do
        get :done
        response.should be_success
      end

      it "should display the done page" do
        get :done
        response.should render_template('done')
      end
    end
  end
end
