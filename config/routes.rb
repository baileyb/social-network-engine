Sne::Application.routes.draw do
  resources :status
  resources :posts, :only => [:index, :new, :create]
	resources :organizations, :only =>[:show]
	get 'context' => 'posts#post_context'
  get 'checkin' => 'posts#checkin'
  get 'signup' => 'facebook_tab_app#signup'
  get 'location' => 'posts#where_am_i'

  # All facebook_tab_app actions just get forwarded
  match ':controller/:action', :controller => /facebook_tab_app/

  match '/search' => 'search#search'

  match '/refresh' => 'posts#refresh'
	
	match '/followUser/:id' => 'users#add_friend'
	
	match '/removeUser/:id' => 'users#remove_friend'
		
	match '/followOrganization/:id' => 'organizations#add_organization'
	
	match '/removeOrganization/:id' => 'organizations#remove_organization'
	
	match'/users/posts/:id' => 'users#posts', :as => :users_posts
	match'/users/followings/:id' => 'users#followings', :as => :users_followings
	match'/users/followers/:id' => 'users#followers', :as => :users_followers
	match'/users/organizations/:id' => 'users#organizations', :as => :users_organizations
	
	match'/organizations/posts/:id' => 'organizations#posts', :as => :organizations_posts
	match'/organizations/followers/:id' => 'organizations#followers', :as => :organizations_followers
	
	match'/reloadPosts' => 'posts#reloadPosts'
	
  devise_for :users, :controllers => { :omniauth_callbacks => 'users/omniauth_callbacks' }

  match 'main' => 'posts#index'
  root :to => 'posts#index'
	resources :users, :only=>[:show]
end
