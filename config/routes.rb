ActionController::Routing::Routes.draw do |map|
  map.resources :documents

  map.root :controller => "home"
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
