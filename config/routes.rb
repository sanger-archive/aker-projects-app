Rails.application.routes.draw do

  root 'nodes#show', id: nil

  resources :nodes

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
