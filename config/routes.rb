Rails.application.routes.draw do

  devise_for :admin, skip: [:registrations, :passwords], controllers: {
    sessions: "admin/sessions"
  }
  namespace :admin do
    resources :members, only: [:index]
  end
  
  get 'homes/admin_top', to: 'homes#admin_top', as: 'admin_top'
  
  
  devise_for :members, skip: [:passwords], controllers: {
    registrations: "member/registrations",
    sessions: 'member/sessions'
  }
  
  get 'homes/member_top', to: 'homes#member_top', as: 'member_top'
  
  
  devise_for :guests, controllers: {
    sessions: 'guests/sessions',
    registrations: 'guests/registrations'
  }
  
  get 'homes/guest_top', to: 'homes#guest_top', as: 'guest_top'
  
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  
  get 'homes/about', to: 'homes#about', as: 'about'

end
