SocialEater::Application.routes.draw do

  resources :places, except: [:destroy,:new,:create,:update] do
    resources :items,except: [:destroy,:new,:create,:update] do
      member do
        post "vote"
        post "unvote"
      end
    end
  end

  devise_for :users, controllers: {
    registrations: "users/registrations",
    sessions: "users/sessions",
    passwords: "users/passwords",
    omniauth_callbacks: "users/omniauth_callbacks"
  }, skip: [:sessions, :registrations]

  namespace :admin do
    resources :places do
      member do
        get "notes"
        post "notes"
      end
      resources :items
      resources :categories
    end
    resources :localities
    resources :cuisines
  end

  #->Prelang (user_login:devise/stylized_paths)
  devise_scope :user do
    get    "login"   => "devise/sessions#new",         as: :new_user_session
    post   "login"   => "devise/sessions#create",      as: :user_session
    delete "signout" => "devise/sessions#destroy",     as: :destroy_user_session
    get    "signup"  => "devise/registrations#new",    as: :new_user_registration
    post   "signup"  => "devise/registrations#create", as: :user_registration
    put    "signup"  => "devise/registrations#update", as: :update_user_registration
    get    "account" => "devise/registrations#edit",   as: :edit_user_registration
  end

  root :to => 'places#index'

  resources :searches do
    collection do
      get :search
      get :places
      get :items_places
    end
  end

end
