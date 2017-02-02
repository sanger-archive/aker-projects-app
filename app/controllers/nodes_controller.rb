class NodesController < ApplicationController
	def show
		if params[:id]
			@node = Node.find(params[:id])
		else
			@node = Node.root
		end
	end

	def create
		p = create_params
		node = Node.create!(p)
		redirect_back(fallback_location: (url_for controller: 'nodes', action: 'show', id: node.parent_id))
	end

private
	def create_params
		{
			name: params.require(:name),
			parent_id: params.require(:parent_id)
		}
	end

	def edit
		@node = Node.find(params[:id])
	end

	def update
		@node = Node.find(params[:id])
		if @node.update_attributes(node_params)
			redirect_to nodes_path
      	else 
      		flash[:error] = "Failed to update node"
      		redirect_to edit_node_path(@node.id)
		end
	end

	private

	def node_params
		params.require(:node).permit(:name)
	end

end
