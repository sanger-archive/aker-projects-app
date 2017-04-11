module Api
  module V1
    class CollectionsController < JSONAPI::ResourceController
      before_action :authenticate_user!
    end
  end
end