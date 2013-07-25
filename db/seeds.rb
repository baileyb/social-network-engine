# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


# Delete all existing users
puts "Deleting existing users"
User.delete_all

# Seed some users
puts "Seeding users"
john, jane = User.create([{:email => 'test@test.org', :password => '11111111',
            :name => 'John Smith', :profile_pic => 'profile-pics/john-smith.jpg'},
            {:email => 'test1@test.org', :password => '11111111',
             :name => 'Jane Lee', :profile_pic => 'profile-pics/jane-lee.jpg'}]
)
p john
p jane

# Making friends
puts "Making friends"
john.friends << jane
jane.friends << john

# Delete all existing posts
puts "Deleting posts"
Post.delete_all

# Seed posts
puts "Seeding posts"
john.posts.create(
    {:text => "I just joined SSN. It is great.", :latitude => 37.4290365, :longitude => -122.16645540000002, :city => "Stanford",
    :zipcode => "94305", :status => "f"}
)

jane.posts.create(
    {:text => "Welcome John. You should be ready for an emergency.", :latitude => 37.4290365, :longitude => -122.16645540000002, :city => "Stanford",
     :zipcode => "94305", :status => "f"}
)

john.posts.create(
    {:text => "My leg is hurt, please help me.", :latitude => 37.4290365, :longitude => -122.16645540000002, :city => "Stanford",
     :zipcode => "94305", :status => "f"},
    {:text => "Are there anybody able to help me?", :latitude => 37.4290365, :longitude => -122.16645540000002, :city => "Stanford",
     :zipcode => "94305", :status => "f"}
)

jane.posts.create(
    {:text => "I will stop by in 5 minutes.", :latitude => 37.4290365, :longitude => -122.16645540000002, :city => "Stanford",
     :zipcode => "94305", :status => "f"}
)

puts "Deleting statuses"
Status.delete_all

puts "Seeding statuses"
# John needs immediate help
john.create_status(
    {:status => "STATUS_NEEDS_HELP",
     :latitude => 37.4290365, :longitude => -122.16645540000002,
     :severity => 2
    }
)

# Jane is OK
jane.create_status(
    {:status => "STATUS_OK",
     :latitude => 37.4290365, :longitude => -122.16645540000002,
     :severity => 0
    }
)




