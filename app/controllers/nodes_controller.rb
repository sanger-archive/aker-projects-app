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
end
