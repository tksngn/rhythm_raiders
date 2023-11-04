Rails.application.routes.draw do
  devise_for :admin, skip: [:registrations, :passwords], controllers: {
    sessions: "admin/sessions"
  }
  devise_for :members, skip: [:passwords], controllers: {
    registrations: "member/registrations",
    sessions: 'member/sessions'
  }
  
  resources :guests, only: [:new, :create]

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
