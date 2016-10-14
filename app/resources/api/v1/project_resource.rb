module Api
  module V1
    class ProjectResource < JSONAPI::Resource
      immutable
      has_many :aims
      attributes :name
    end
  end
end
