Rails.application.routes.draw do
  get 'search', to: 'search#index'
  get 'attachments/*path', to: 'docs#attach'

  get 'description', to: 'pages#description'
  get 'advancedsearch', to: 'pages#advanced'
  
  root to: 'docs#index'
  resources :docs

  # Aliases for legacy support
  get 'nsadocs', to: 'docs#index'
  get 'nsadocs/:id', to: 'docs#show'
end
