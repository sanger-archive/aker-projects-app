module Api
  module V1
    class AimResource < JSONAPI::Resource
      immutable
      has_many :proposals
      attributes :name
    end
  end
end
