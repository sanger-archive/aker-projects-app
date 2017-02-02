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
		redirect_to node_path(node.parent_id)
	end

	def edit
		@node = Node.find(params[:id])
	end

	def update
		@node = Node.find(params[:id])
		if @node.update_attributes(node_params)
			redirect_to node_path(@node.parent_id)
      	else 
      		flash[:error] = "Failed to update node"
      		redirect_to edit_node_path(@node.id)
		end
	end

	def destroy
		@node = Node.find(params[:id])

		if @node.children.any?
			flash[:danger] = "A node with children cannot be deleted"
			redirect_to node_path(@node.parent_id)
			return
		end

		if @node.destroy
			puts "node deleted"
			flash[:success] = "Node deleted"
			redirect_to node_path(@node.parent_id)
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
