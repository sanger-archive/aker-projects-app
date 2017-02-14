module Api
  module V1
    class NodeResource < JSONAPI::Resource
      immutable
      has_many :nodes
      has_one :parent
      attributes :name
    end
  end
end
