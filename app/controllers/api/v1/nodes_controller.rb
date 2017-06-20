module Api
  module V1
    class NodesController < JSONAPI::ResourceController
      include JWTCredentials

      def context
        { current_user: current_user}
      end
	  end
  end
end
