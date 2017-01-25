module Api
  module V1
    class ProgramResource < JSONAPI::Resource
      immutable
      has_many :projects
      has_one :collection
      attributes :name
    end
  end
end
