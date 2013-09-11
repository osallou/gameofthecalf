GameOfTheCalf::Application.routes.draw do

  devise_for :markets
  resources :markets
  as :market do
    post 'markets/:id/selection' => 'markets#selection'
  end

  devise_for :game_configs
  resources :game_configs

  devise_for :levels
  resources :levels

  devise_for :games
  resources :games
  as :game do
    post 'games/:id/nextlevel' => 'games#nextlevel', :as => 'next_level'
  end


  root :to => 'game#welcome'

  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)


  resources :groups


  #devise_for :users
  devise_for :users, :skip => [:registrations] 
  as :user do
    get 'users/edit' => 'devise/registrations#edit', :as => 'edit_user_registration'
    put 'users' => 'devise/registrations#update', :as => 'user_registration'
  end


  resources :users

  devise_for :groups
  as :group do
    post 'groups/:id/generateusers' => 'groups#generateusers', :as => 'generate_users'
    get 'groups/:id/nextlevel' => 'groups#nextlevel', :as => 'next_group_level'
    get 'groups/:id/games/:gid/forcenextlevel' => 'groups#forcenextlevel', :as => 'group_force_next_level'
    get 'groups/:id/market/open' => 'groups#open_market', :as => 'open_market'
    get 'groups/:id/market/close' => 'groups#close_market', :as => 'close_market'
    get 'groups/:id/market/cancel' => 'groups#cancel_market', :as => 'cancel_market'
    get 'groups/:id/market/bids' => 'groups#bids_market', :as => 'bids_market'
  end

  match 'users/create' => 'users#create', :via => :post, :as => :create_user

  match 'game/locale/:id' => 'game#locale'

  match 'credits' => 'game#credits'

  match 'tutorial' => 'game#tutorial'

  match 'game/admin' => 'game#admin', :via => :get


end
