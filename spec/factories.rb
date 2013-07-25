FactoryGirl.define do
  # Users
  factory :brian, class: User do
    name "Brian Bailey"
    email "brian.bailey@sv.cmu.edu"
    uid "1"
    password "password"
    posts {[FactoryGirl.create(:post_by_brian)]}
  end

  factory :james, class: User do
    name "James Ricks"
    email "james.ricks@sv.cmu.edu"
    uid "2"
    password "password"
  end

  factory :jason, class: User do
    name "Jason Leng"
    email "jason.leng@sv.cmu.edu"
    uid "3"
    password "password"
    organizations {[FactoryGirl.create(:org3)]}
    friends {[FactoryGirl.create(:brian)]}
  end

  factory :victor, class: User do
    name "Victor Marmol"
    email "victor.marmol@sv.cmu.edu"
    uid "4"
    password "password"
  end

  factory :user5, class: User do
    name "User #5"
    email "user5@sv.cmu.edu"
    uid "5"
    password "password"
  end

  # Organizations
  factory :org1, class: Organization do
    name "Organization 1"
    facebook_id "o1"
    is_city false
  end

  factory :org2, class: Organization do
    name "Organization 2"
    facebook_id "o2"
    is_city false
  end

  factory :org3, class: Organization do
    name "Organization 3"
    facebook_id "o3"
    is_city false
    posts {[FactoryGirl.create(:post_by_org3)]}
  end

  # Cities
  factory :city1, class: Organization do
    name "City 1"
    facebook_id "c1"
    is_city true
  end

  factory :city2, class: Organization do
    name "City 2"
    facebook_id "c2"
    is_city true
  end

  factory :city3, class: Organization do
    name "City 3"
    facebook_id "c3"
    is_city true
  end
	
	factory :post1, class: Post do
		text "Test Post"		
  end

  factory :post_by_org3, :class => Post do
    text "Post by org3"
    updated_at "2013-03-25 07:22:48.056538"
  end

  factory :post_by_brian, :class => Post do
    text "Post by brian"
    updated_at "2013-03-26 07:22:48.056538"
  end
end
