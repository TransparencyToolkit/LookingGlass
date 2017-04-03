Rails.application.routes.draw do
  get 'search', to: 'search#index'
  get 'docs/makedocview', to: 'docs#makedocview'

  get 'description', to: 'docs#description'
  get 'advancedsearch', to: 'docs#advanced'
  get 'otherresources', to: 'docs#otherresources'
  
  root to: 'docs#index'
  resources :docs

  # Aliases for legacy support
  get 'nsadocs', to: 'docs#index'
  get 'nsadocs/:id', to: 'docs#show'
end
