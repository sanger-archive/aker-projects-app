require 'billing_facade_client'
require 'data_release_strategy_client'

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


  ### Data release helpers

  # Gets the list of available data release strategies for a user and creates a hash from it where the 
  # key is the name of the strategy, and the value is the uuid.
  # If the request fails, just return the current option.
  def data_release_strategy_options(selected_option, opts, html_options)
    begin
      DataReleaseStrategyClient.find_strategies_by_user(current_user.email).reduce(selected_option) do |memo, strategy|
        # We remove any previous occur for the same uuid (this will happen when someone changes the name of the)
        # strategy name in the remote service, so it is different from our cached value in the database
        memo.select do |k,v|
          v == strategy.id
        end.tap do |k,v|
          memo.delete(k)
        end

        memo[strategy.label_to_display] = strategy.id
        memo
      end
    rescue StandardError => e
      opts[:error_msg] = "There was a problem while connecting to the Data release strategy service"
      html_options[:disabled] = true      
      selected_option
    end
  end

  def data_release_strategy_no_strategy_option
    {'No strategy'=> ""}
  end

  def data_release_strategy_selected_strategy_option(node)
    { node.data_release_strategy.label_to_display => node.data_release_strategy_id }
  end

  def data_release_strategies_select_for(node, f, opts={}, html_options={})
    if node.data_release_strategy_id.nil?
      selected_option = data_release_strategy_no_strategy_option
    else
      selected_option = data_release_strategy_selected_strategy_option(node)
    end

    if (opts[:async] == true)
      options = options_for_select(selected_option, selected_option.values.first)
      html_options['data-psd-async'] = true
      if (opts[:cached] == true)
        html_options['data-psd-cached'] = true
      end
    else
      options = options_for_select(data_release_strategy_options(selected_option.dup, opts, html_options), selected_option.values.first)
    end
    opts = opts.reject{|k,v| k == :async || k == :cached}
    if node.data_release_strategy
      html_options[:title] = node.data_release_strategy.name
    end

    out = [f.select(:data_release_strategy_id, options, opts, html_options)]
    unless opts[:async] == true
      if opts[:error_msg]
        out.push(display_error_in_form('data_release_strategy_id', opts[:error_msg]))
      end
    end
    out.join.html_safe
  end


end
