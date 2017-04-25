module Api
  module V1
    class CollectionsController < JSONAPI::ResourceController
      include JWTCredentials
      #before_action :check_credentials
      #before_action :apply_credentials
    end
  end
end