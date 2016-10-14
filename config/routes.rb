Rails.application.routes.draw do

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

    end
  end

end
