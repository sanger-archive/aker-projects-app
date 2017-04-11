module Api
  module V1
    class NodesController < JSONAPI::ResourceController
      before_action :authenticate_user!

	end
  end
end
