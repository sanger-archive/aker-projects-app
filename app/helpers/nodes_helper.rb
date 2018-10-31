# frozen_string_literal: true

module NodesHelper

  def linknode(node)
    link_to node.name, node_path(node.id)
  end

  def edit_node(node)
    link_to 'Edit', edit_node_path(node.id)
  end

  def delete_node(node)
    link_to 'Delete', node, method: :delete, data: { confirm: 'Are you sure you want to delete this node?' }
  end

end
