Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'nodes#show', id: nil

  health_check_routes

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

  resources :tree_layouts, only: [:create, :index] do
    collection do
      delete '', to: 'tree_layouts#destroy'
    end
  end

  namespace :api do
    namespace :v1 do
      # https://github.com/cerebris/jsonapi-resources#routing
      jsonapi_resources :nodes do
        jsonapi_relationships
      end
    end
  end
end
