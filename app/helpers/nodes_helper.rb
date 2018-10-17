
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

  ### Error handling helpers

  def display_error_in_form(field, msg)
    "<script type='text/javascript'>$('form', 'div.modal-body').render_form_errors('node_form', {#{field}: ['#{msg}']});</script>"
  end

  ### Cost codes helpers

  def subcostcodes_select_options(node, selected_option, opts, html_options)
    begin
      parent_cost_code = node.parent.cost_code
      BillingFacadeClient.get_sub_cost_codes(parent_cost_code)
    rescue StandardError => e
      unless opts[:async] == true
        opts[:error_msg] = "There was a problem while connecting to the Billing service"
      end
      html_options[:disabled] = true
      selected_option
    end
  end

  def sub_costcodes_no_costcode_option
    {'No costcode selected'=> ""}
  end

  def subcostcodes_select_for(node, f, opts={}, html_options={})
    if node.cost_code.nil?
      selected_option = sub_costcodes_no_costcode_option
    else
      selected_option = { node.cost_code => node.cost_code }
    end
    option_elements = options_for_select(subcostcodes_select_options(@node, selected_option, opts, html_options), selected_option.values.first)
    out = [f.select(:cost_code, option_elements, opts, html_options)]
    if opts[:error_msg]
      out.push(display_error_in_form('cost_code', opts[:error_msg]))
    end
    out.join.html_safe
  end

end
