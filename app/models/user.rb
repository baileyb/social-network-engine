class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable
		 
  validates_presence_of :email

  # Setup accessible (or protected) attributes for your model
  attr_accessible :name, :profile_pic, :email, :password, :password_confirmation, :remember_me, :token_expiration, :provider, :uid, :token
  has_many :posts, :dependent => :destroy

  has_one :status, :dependent => :destroy

  # The user's friends
  has_and_belongs_to_many :friends, :class_name => "User", :foreign_key => "user_id", :association_foreign_key => "friend_id", :join_table => "friends_users"
	has_and_belongs_to_many :followers, :class_name => "User", :foreign_key => "friend_id", :association_foreign_key => "user_id", :join_table => "friends_users"

  # The organizations the user administers
  has_and_belongs_to_many :organizations_managed, :class_name => "Organization", :foreign_key => "user_id", :association_foreign_key => "organization_id", :join_table => "organization_administrators"

  # The organizations the user is interested in
  has_and_belongs_to_many :organizations

  # Allows us to mock util for tests
  @@util_save_picture = Util.method(:save_picture)

  def UpdateFriends(facebook_friend_ids)
    # Look for existing users who are Facebook friends
    existing_friends = User.find(:all, :conditions => ["uid IN (?)", facebook_friend_ids])
    if not existing_friends.nil?
      # Mirror the friends in Facebook
      self.friends.destroy_all
      self.friends << existing_friends
    end
  end

  def UpdateOrganizations(org_ids)
    # Look for existing organizations that exist in SSN
    existing_orgs = Organization.find(:all, :conditions => ["facebook_id IN (?)", org_ids])
    if not existing_orgs.nil?
      # Mirror the organizations in Facebook
      self.organizations.destroy_all
      self.organizations << existing_orgs
    end
  end

  def UpdateProfilePicture(profile_pic)
    profile_pic_name = @@util_save_picture.call(profile_pic)
    self.profile_pic = profile_pic_name
    self.save!
  end

  # Updates a user's friends, organizations, and profile picture. 
  # TODO: Make this smarter about downloading the picture, try not to change it
  # if it has not changed.
  def UpdateData(friend_ids, org_ids, profile_pic)
    self.UpdateFriends(friend_ids)
    self.UpdateOrganizations(org_ids)
    self.UpdateProfilePicture(profile_pic)
  end
end
