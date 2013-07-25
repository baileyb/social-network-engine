class Post < ActiveRecord::Base
  attr_accessible :text, :address, :latitude, :longitude, :status, :city, :zipcode
  belongs_to :user
  belongs_to :organization
  validates :text, :length => {
      :minimum   => 1,
      :maximum   => 140,
      :tokenizer => lambda { |str| str.scan(/\w+/) }
  }
  geocoded_by :address
  after_validation :geocode
  reverse_geocoded_by :latitude, :longitude do |obj,results|
    geo = results.first
    unless geo.nil?
      obj.city = geo.city
      obj.zipcode = geo.postal_code
    end
  end
  after_validation :reverse_geocode

  ALL_CLEAR_STATUS = "STATUS_OK"
  NEEDS_ASSISTANCE_STATUS = "STATUS_NEEDS_ASSISTANCE"
  NEEDS_HELP_STATUS = "STATUS_NEEDS_HELP"
  ALL_STATUSES = [ALL_CLEAR_STATUS, NEEDS_ASSISTANCE_STATUS, NEEDS_HELP_STATUS] 
  
  POST_AS_SELF = "SELF"

  validates_inclusion_of :text, :in => ALL_STATUSES, :if => :status?

  def status?
    status == true
  end

  # Filters all posts to those this user is interested in. Also limits the posts
  # returned and allows the specification of an offset.
  # Pass last_id a hash to load newer or older posts, such as {:id=>1, :backward=>false}.
  # :backward => true will load older posts and :backward => false will load newer posts.
  # When last_id is an Id value, new posts will be retrieved.
  # If filter is false, all posts are fetched. Otherwise, we get the posts for
  # the user's friends, organizations, and all cities.
  def self.Filter(user, limit, last_id, location=nil, radius=nil, filter=false) 
    if filter
      # Get the IDs of all organizations the user is following
      org_ids = user.organizations.map{|o| o.id}

      # Add the IDs of the cities since all cities are organizations
      org_ids += Organization::AllCities().map{|c| c.id}

      # Get the IDs of all friends
      friend_ids = user.friends.map{|f| f.id}

      # Include the user's own posts
      friend_ids << user.id

      filter_conditions = ["(user_id IN (?) OR organization_id IN (?))", friend_ids, org_ids]
    else
      # Just get all posts.
      filter_conditions = ""
    end

    # Get posts after the last ID if one was specified
    if last_id.nil? || last_id.length == 0
      conditions = filter_conditions

    else
      if last_id.kind_of?(Hash)
        if last_id[:backward]
          conditions = ["id < ?", last_id[:id]]
        else
          conditions = ["id > ?", last_id[:id]]
        end
      else # last_id is a single Id value
        conditions = ["id > ?", last_id]
      end

      # Add the filters if they exist.
      if not filter_conditions.empty?
        conditions[0] = conditions[0] + " AND " + filter_conditions[0]
        conditions.push(filter_conditions[1])
        conditions.push(filter_conditions[2])
      end
    end

    # Include the user information
    unless  location.is_a? Array
      location = "'#{location}'"
    end

    geoCondition = (!location.nil? && !radius.nil?) ? ".near(#{location}, #{radius.to_i}, :order=>'distance')" : ''
    eval("Post.includes([:user, :organization])#{geoCondition}.find(:all,
        :conditions => conditions,
        :limit => limit,
        :order => 'updated_at DESC')")
  end


  def self.max_distance_from_position(user, location)
    return 0 if location.nil?
    posts = Post.Filter(user, 100, nil)
    max_distance = 0
    posts.each do |post|
      distance = Geocoder::Calculations.distance_between(location, [post.latitude, post.longitude])
      max_distance = distance if distance > max_distance
    end
    max_distance
  end
end
