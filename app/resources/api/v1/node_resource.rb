module Api
  module V1
    class NodeResource < JSONAPI::Resource

      has_many :nodes
      has_many :permissions, class_name: 'Permission', relation_name: :permissions
      has_one :parent
      attributes :name, :cost_code, :description, :node_uuid, :writable, :owned_by_current_user, :editable_by_current_user

      before_create :set_owner

      # We need to be able to find all records that have a cost_code (i.e. proposals)
      # Unfortunately, JSONAPI's spec does not have a standard way to filter where an
      # attribute is or is not NULL, so implementing our own.
      #
      # Using _none to find all records with cost_code NULL
      # e.g. /api/v1/nodes?filter[cost_code]=_none
      #
      # Using !_none to find all records with cost_node NOT NULL
      # e.g. /api/v1/nodes?filter[cost_code]=!_none
      filter :cost_code, apply: ->(records, value, _options) {
        if value[0] == '_none'
          records.where('cost_code': nil)
        elsif value[0] == '!_none'
          records.where.not('cost_code': nil)
        else
          records.where('cost_code': value)
        end
      }

      filter :active, default: "true", apply: -> (records, value, _options) {
        (value[0].downcase == "true") ? records.where(deactivated_by: nil) : records.where.not(deactivated_by: nil)
      }

      filter :readable_by, apply: ->(records, value, _options) {
        records.joins(:permissions).where('permissions.permission_type': 'read', 'permissions.permitted': value)
      }

      filter :writable_by, apply: ->(records, value, _options) {
        records.joins(:permissions).where('permissions.permission_type': 'write', 'permissions.permitted': value)
      }

      filter :spendable_by, apply: ->(records, value, _options) {
        records.joins(:permissions).where('permissions.permission_type': 'spend', 'permissions.permitted': value)
      }

      # check whether the node is owned by the current user.
      # returns a bool
      def owned_by_current_user
        context[:current_user] && @model.owner_email == context[:current_user].email
      end

      def editable_by_current_user
        if context[:current_user].nil?
          return false
        end
        if @model.owner_email && @model.owner_email==context[:current_user].email
          return true
        end
        if @model.permissions.where(permitted: context[:current_user].email, permission_type: "write").count > 0
          return true
        end
        context[:current_user].groups.each do |group|
          if @model.permissions.where(permitted: group, permission_type: "write").count > 0
            return true
          end
        end
        return false
      end

      def meta(options)
        {
          active: _model.active?
        }
      end

      def remove
        unless @model.deactivate(context[:current_user]&.email)
          raise JSONAPI::Exceptions::BadRequest, "This node cannot be deactivated"
        end
      end

      def set_owner
        @model.owner_email = context[:current_user]&.email
      end

      def writable
        context[:current_user] && Ability.new(context[:current_user]).can?(:write, @model)
      end

    end
  end
end
