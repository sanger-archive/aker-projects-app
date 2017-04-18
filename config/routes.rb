Rails.application.routes.draw do

  root 'nodes#show', id: nil

  resources :nodes do
    collection do
      get 'list'
      get 'tree'
    end

    member do
      get 'list'
      get 'tree'
    end
  end

  namespace :api do
    namespace :v1 do
      # https://github.com/cerebris/jsonapi-resources#routing

      jsonapi_resources :collections

      jsonapi_resources :nodes do
        jsonapi_relationships
      end

    end
  end

end
