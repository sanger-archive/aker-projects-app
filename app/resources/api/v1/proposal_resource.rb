module Api
  module V1
    class ProposalResource < JSONAPI::Resource
      immutable
      attributes :name
    end
  end
end
