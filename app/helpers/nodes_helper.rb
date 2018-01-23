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

  def subcostcodes_select_options(node)
    parent_cost_code = node.parent.cost_code
    BillingFacadeClient.get_sub_cost_codes(parent_cost_code)
  end

  # Gets the list of available data release strategies for a user and creates a hash from it where the 
  # key is the name of the strategy, and the value is the uuid.
  def data_release_strategy_options(selected_option)
    DataReleaseStrategyClient.find_strategies_by_user(current_user.email).reduce(opts) do |memo, strategy|
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
  end

  def data_release_strategy_no_strategy_option
    {'No strategy'=> ""}
  end

  def data_release_strategy_selected_strategy_option
    { @node.data_release_strategy.label_to_display => @node.data_release_strategy_id }
  end

  def data_release_strategies_select_for(f, opts)
    if @node.data_release_strategy_id.nil?
      selected_option = data_release_strategy_no_strategy_option
    else
      selected_option = data_release_strategy_selected_strategy_option
    end

    if (opts[:async] == true)
      options = options_for_select(selected_option, selected_option.values.first)
    else
      options = options_for_select(data_release_strategy_options(selected_option), selected_option)
    end
    html_options = {disabled: opts[:async] || !write_permission}
    if @node.data_release_strategy
      html_options[:title] = @node.data_release_strategy.name
    end
    f.select :data_release_strategy_id, options,
        {include_blank: true}, html_options

  end


end
