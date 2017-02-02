class NodesController < ApplicationController
	
	def index
		@nodes = Node.all
	end

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

	def destroy
		@node = Node.find(params[:id])

		if @node.parent == nil
			flash[:danger] = "Cannot delete the root node"
			redirect_to nodes_path
			return
		end

		if @node.children.any?
			puts "node has children"
			p @node
			flash[:danger] = "Cannot delete node with children"
			redirect_to nodes_path
			return
		end

		if @node.destroy
			puts "node deleted"
			flash[:success] = "Node deleted"
			redirect_to nodes_path
		else
			puts "node not deleted"
			flash[:error] = "Node could not be deleted"
			redirect_to edit_node_path(@node.id)
		end
	end

	private

	def create_params
		{
			name: params.require(:name),
			parent_id: params.require(:parent_id)
		}
	end

	def node_params
		params.require(:node).permit(:name)
	end

end
