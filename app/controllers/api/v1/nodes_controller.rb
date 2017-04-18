module Api
  module V1
    class NodesController < JSONAPI::ResourceController
      include JWTCredentials
	  end
  end
end
