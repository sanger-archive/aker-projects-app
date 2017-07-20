module Api
  module V1
    class PermissionResource < JSONAPI::Resource

      immutable
      model_name '::AkerPermissionGem::Permission'
      has_one :accessible, polymorphic: true
      attributes :permission_type, :permitted

    end
  end
end