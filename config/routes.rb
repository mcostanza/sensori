Sensori::Application.routes.draw do

  resources :features
  resources :playlists

  resources :tutorials, :except => :destroy do
    post "preview", :on => :member
  end
  
  resources :sessions do
    resources :submissions, :only => [:create, :update, :destroy]
  end
  get "sessions/:id/submissions", :to => "sessions#submissions", :as => "session_submissions"

  resources :discussions

  resources :responses, :only => [:create, :update, :destroy]

  get "members/sign_in"
  get "members/sign_out"
  get "members/soundcloud_connect"
  resources :members, :only => [:update, :show]

  match "beats" => "tracks#index", :via => "get"

  get "home/index"
  match "about" => "home#about", :via => "get"

  match "kickstarter"  => "home#kickstarter", :via => "get"
  get '/tagged/*tag'   => "home#blog_tag_redirect",  :format => false
  get '/post/*post_id' => "home#blog_post_redirect", :format => false

  get "/:id" => "members#show", :as => :member_profile
  
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :to => 'home#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
