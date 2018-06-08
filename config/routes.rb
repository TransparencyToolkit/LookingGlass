Rails.application.routes.draw do
  get 'search', to: 'search#index'
  get 'attachments/*path', to: 'docs#attach'

  get 'description', to: 'pages#description'
  get 'free_press_legal_description', to: 'pages#free_press_legal_description'
  get 'advancedsearch', to: 'pages#advanced'
  get 'document_suggest', to: 'pages#document_suggest'
  get 'document_sent', to: 'pages#document_sent'
  get 'datapolitics_description', to: 'pages#datapolitics_description'
  get 'datapolitics_suggest', to: 'pages#datapolitics_suggest'

  root to: 'docs#index'
  resources :docs

  # Aliases for legacy support
  get 'nsadocs', to: 'docs#index'
  get 'nsadocs/:id', to: 'docs#show'
end
