class NodesController < ApplicationController

	def index
		@nodes = Node.all
	end

	def show
		@node = Node.find(params[:id])
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
