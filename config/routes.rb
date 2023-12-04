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

  devise_for :members, skip: [:passwords], controllers: {
    registrations: "member/registrations",
    sessions: 'member/sessions'
  }

  namespace :member do
    resources :customers, only: [:index, :show, :edit, :update] do
      collection do
        get :follows, :followers
        get :mypage
        get :unsubscribe
        patch :withdraw
      end
      resource :relationships, only: [:create, :destroy]
    end

    resources :created_tracks, only: [:new, :create, :index, :show, :destroy] do
      resources :post_comments, only: [:create, :destroy]
      resources :likes, only: [:create, :destroy]

      collection do
        get :guest_index
      end
    end
  end

  post '/member/customers/guest_sign_in', to: 'member/customers#guest_sign_in'
  get 'member_top', to: 'homes#member_top'
  get 'homes/about', to: 'homes#about', as: 'about'
  get 'search', to: 'search#index', as: 'search_index'

end
