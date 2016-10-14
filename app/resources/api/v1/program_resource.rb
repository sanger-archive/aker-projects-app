module Api
  module V1
    class ProgramResource < JSONAPI::Resource
      immutable
      has_many :projects
      attributes :name
    end
  end
end
