ActionController::Routing::Routes.draw do |map|
  map.resources :documents, :comments #, :users
  map.root :controller => "documents"
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
