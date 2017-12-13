require 'billing_facade_client'

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

  def subcostcodes_select_options(node)
    parent_cost_code = node.parent.cost_code
    BillingFacadeClient.get_sub_cost_codes(parent_cost_code)
  end

end
