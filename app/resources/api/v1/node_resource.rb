module Api
  module V1
    class NodeResource < JSONAPI::Resource

      has_many :nodes
      has_one :parent
      attributes :name, :cost_code, :description, :node_uuid

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
        (value[0].downcase == "true") ? records.where(deactivated_by_id: nil) : records.where.not(deactivated_by_id: nil)
      }

      def meta(options)
        {
          active: _model.active?
        }
      end

      def remove
        @model.deactivate(context[:current_user])
      end

      def set_owner
        @model.owner = context[:current_user]
      end

    end
  end
end
