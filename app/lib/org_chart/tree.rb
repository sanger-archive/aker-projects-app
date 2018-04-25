# Helps build the datasource for OrgChart
# https://github.com/dabeng/OrgChart#structure-of-datasource
module OrgChart
  class Tree

    attr_reader :node, :id, :name, :owner, :cost_code, :href, :parentId

    def initialize(options)
      @node      = options.fetch(:node)
      @nodes     = options.fetch(:nodes, nil)
      @id        = @node.id.to_s
      @name      = @node.name
      @owner     = @node.owner_email
      @cost_code = @node.cost_code
      @parentId  = @node.parent_id.to_s
    end

    def node_type
      return 'project' if node.is_project?
      return 'sub-project' if node.is_subproject?
      return 'organisational'
    end

    def href
      id
    end

    def relationship
      relationship = "000"
      relationship[0] = "1" if node.parent_id?
      relationship[1] = "1" if has_sibling?(node)
      relationship[2] = "1" if children_for(node).length > 0
      return relationship
    end

    def writers
      node.permissions.lazy
        .select { |perm| perm.permission_type == 'write' }
        .map { |perm| perm.permitted }
        .force
    end

    def spenders
      node.permissions.lazy
        .select { |perm| perm.permission_type == 'spend' }
        .map { |perm| perm.permitted }
        .force
    end

    def to_h
      {
        id: id,
        cost_code: cost_code,
        node_type: node_type,
        name: name,
        href: href,
        relationship: relationship,
        parentId: parentId,
        owner: owner,
        writers: writers,
        spenders: spenders,
        children: children
      }
    end

    def to_json
      ActiveSupport::JSON.encode(to_h)
    end

    private

    # Get all nodes in a format where relationships and permissions don't have to be
    # looked up in the db all the time
    #
    # Returns a map where a key is a node's id and value is a list of its children
    def nodes
      @nodes ||= Node.active.includes(:permissions, :parent)
                  .order(created_at: :asc)
                  .reduce({}) { |memo, node| assign_to_parent(memo, node) }
    end

    def assign_to_parent(memo, node)
      if !node.parent_id.nil?
        if memo.has_key?(node.parent_id.to_s)
          memo[node.parent_id.to_s].push(node)
        else
          memo[node.parent_id.to_s] = [node]
        end
      end
      memo
    end

    def has_sibling?(node)
      return false if !nodes.has_key?(node.parent_id.to_s)
      nodes[node.parent_id.to_s].length > 1
    end

    def children_for(node)
      return nodes.has_key?(node.id.to_s) ? nodes[node.id.to_s] : []
    end

    def children
      children_for(node).map { |node| OrgChart::Tree.new(node: node, nodes: nodes).to_h }
    end
  end
end