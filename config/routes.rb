Rails.application.routes.draw do
  root to: 'homes#member_top'

  devise_for :admin, skip: [:registrations, :passwords], controllers: {
    sessions: "admin/sessions"
  }

  namespace :admin do
    resources :members, only: [:index, :show, :edit, :update] do
      member do
        get :suspend
        post :unban
      end
    end
    resources :posts, only: [:index, :show, :destroy] do
      member do
        get :suspend
        patch :suspend
      end
    end
  end

  get 'homes/admin_top', to: 'homes#admin_top', as: 'admin_top'

  devise_for :members, skip: [:passwords], controllers: {
    registrations: "member/registrations",
    sessions: 'member/sessions'
  }

  namespace :member do
    resources :customers do
      collection do
        get :mypage
        get :edit
        patch :update
        get :unsubscribe
        patch :withdraw
      end
    end
  end

  devise_for :guests, controllers: {
    sessions: 'guests/sessions',
    registrations: 'guests/registrations'
  }

  resources :created_tracks
  get 'homes/about', to: 'homes#about', as: 'about'
  get 'search', to: 'search#index', as: 'search_index'

end
