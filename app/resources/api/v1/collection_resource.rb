module Api
  module V1
    class CollectionResource < JSONAPI::Resource
      immutable
      attributes :set_id
    end
  end
end
