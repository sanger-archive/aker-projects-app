module NodesHelper
	# Gets the parents of a node,
	# starting from root, ending at the node's direct parent
  def parents(node)
  	parents = []
  	p = node.parent
  	while p do
  		parents.unshift(p)
  		p = p.parent
  	end
  	parents
  end

  def linknode(node)
  	link_to node.name, node_path(node.id)
  end

  def edit_node(node)
    link_to "Edit", edit_node_path(node.id)
  end

  def delete_node(node)
    link_to 'Delete', node, method: :delete, data: { confirm: 'Are you sure you want to delete this node?' } 
  end

end
