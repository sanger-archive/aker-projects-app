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
  	link_to node.name, controller: "nodes", action: "show", id: node.id
  end
end
