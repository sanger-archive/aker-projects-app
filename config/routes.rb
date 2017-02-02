Rails.application.routes.draw do

  root 'nodes#show', id: nil

  resources :programs, only: [:show]
  resources :projects, only: [:show]
  resources :aims, only: [:show]
  resources :proposals, only: [:show]
  resources :nodes, only: [:show, :create]

  namespace :api do
    namespace :v1 do

      # https://github.com/cerebris/jsonapi-resources#routing
      jsonapi_resources :programs do
        jsonapi_relationships
      end

      jsonapi_resources :projects do
        jsonapi_relationships
      end

      jsonapi_resources :aims do
        jsonapi_relationships
      end

      jsonapi_resources :proposals

      jsonapi_resources :collections

    end
  end

end
