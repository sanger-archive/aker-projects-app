module Api
  module V1
    class NodeResource < JSONAPI::Resource

      has_many :nodes
      has_many :permissions, class_name: 'Permission', relation_name: :permissions
      has_one :parent
      attributes :name, :cost_code, :description, :node_uuid, :writable, :updated_at, :created_at,
                 :owned_by_current_user, :editable_by_current_user,
                 :is_project_node, :is_sub_project_node, :parent_id, :spendable_by_current_user
      before_create :set_owner

      after_create :publish_created
      after_update :publish_updated
      # after_replace_to_one_link would also make sense,
      #  but moving a node ALSO triggers 'update', so it is covered.

      # We need to be able to find all records that have a cost_code
      # (i.e. proposals)
      # Unfortunately, JSONAPI's spec does not have a standard way to filter
      # where an attribute is or is not NULL, so implementing our own.
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

      filter :node_type, apply: ->(records, value, _options) {
        if value[0] == 'project'
          records.is_project
        elsif value[0] == 'subproject'
          records.is_subproject
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

      filter :with_parent_spendable_by, apply: ->(records, value, _options) {
        records.joins(parent: :permissions).where('permissions.permission_type': 'spend', 'permissions.permitted': value)
      }

      # check whether the node is owned by the current user.
      # returns a bool
      def owned_by_current_user
        context[:current_user] && @model.owner_email == context[:current_user].email
      end

      def spendable_by_current_user
        if context[:current_user].nil?
          return false
        end
        if @model.permissions.where(permitted: context[:current_user].email, permission_type: "spend").count > 0
          return true
        end
        context[:current_user].groups.each do |group|
          if @model.permissions.where(permitted: group, permission_type: "spend").count > 0
            return true
          end
        end
        return false
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

      # Returns true if the node is a project node, i.e has a regular cost code such as S1234
      def is_project_node
        @model.is_project?
      end

      # Returns true if the node is a sub-project node, i.e if it is inside a project node
      def is_sub_project_node
        @model.is_subproject?
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
        publish_updated
      end

      def set_owner
        @model.owner_email = context[:current_user]&.email
      end

      def writable
        context[:current_user] && Ability.new(context[:current_user]).can?(:write, @model)
      end

      def publish_created
        message = EventMessage.new(node: @model, event: 'created', trace_id: context[:request_id], user: context[:current_user].email)
        EventService.publish(message)
      end

      def publish_updated
        message = EventMessage.new(node: @model, event: 'updated', trace_id: context[:request_id], user: context[:current_user].email)
        EventService.publish(message)
      end

    end
  end
end
