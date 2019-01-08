module Api
  module V1
    class NodesController < JSONAPI::ResourceController
      include JWTCredentials
  	  include AkerPermissionControllerConfig
      include WebSocketsNotification

      skip_authorization_check only: [:index, :show, :get_related_resource]

      skip_credentials only: [:show]

      def create
        authorize! :create, Node, message: 'You are not authorized to create this node.'
        authorize! :write, parent_node, message: 'You are not authorized to create children nodes under the selected parent node'
        super
        notify_changes_with_websockets
      end

      def update
        authorize! :write, current_node, message: 'You are not authorized to update this node'
        super
        notify_changes_with_websockets
      end

      def destroy
        authorize! :write, current_node, message: 'You are not authorized to delete this node.'
        @node.deactivate(current_user.email)
        super
        notify_changes_with_websockets
      end

      def update_relationship
        authorize! :write, update_current_node, message: 'You are not authorized to update this node.'
        authorize! :write, update_parent_node, message: 'You are not authorized to update children nodes under the selected parent node'
        super
        notify_changes_with_websockets
      end

      def context
        { current_user: current_user, request_id: request.request_id }
      end

      private

      def parent_node
        Node.find_by_id(params[:data][:relationships][:parent][:data][:id])
      end

      def current_node
        @node = (params[:id] && Node.find_by_id(params[:id])) || Node.root
      end

      def update_parent_node
        Node.find_by_id(params[:data][:id])
      end

      def update_current_node
        @node = (params[:node_id] && Node.find_by_id(params[:node_id])) || Node.root
      end

	  end
  end
end
