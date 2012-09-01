ActionController::Routing::Routes.draw do |map|
  map.root :controller => "home"
  
  map.callback "/callback/:provider", :controller => "home", :action => "callback"
  map.friends "/friends", :controller => "home", :action => "friends_list"
  map.invite_friends "/invite_friends", :controller => "users", :action => "invite_friends"
  map.gifts "/gifts/:id", :controller => "users", :action => "gifts"
  map.gift_like "/gift_likes", :controller => "users", :action => "gift_likes"
  
  map.get_amazon_data  "get_amazon_data/:id",:controller => "users",:action => "get_amazon_data"
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'

  map.resources :users 
  

end
