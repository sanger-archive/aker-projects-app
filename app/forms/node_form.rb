class NodeForm

  # ActiveModel plumbing to make `form_for` work
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  def persisted?
    false
  end

  ATTRIBUTES = [:id, :parent_id, :name, :description, :cost_code, :user_writers, :group_writers, :user_spenders, :group_spenders]

  JOINED_LISTS = [:user_writers, :group_writers, :user_spenders, :group_spenders]

  attr_accessor *ATTRIBUTES

  def initialize(attributes = {})
    ATTRIBUTES.each do |attribute|
      value = attributes[attribute]
      send("#{attribute}=", value)
    end
    @owner = attributes[:owner]
  end

  def parent_id
    @parent_id ||= parent&.id
  end

  def save
    #TODO valid? currently does nothing
    valid? && (id ? update_objects : create_objects)
  end

  def self.from_node(node)
    new(id: node.id, parent_id: node.parent_id, name: node.name, description: node.description,
        cost_code: node.cost_code, user_writers: node_permitted(node, :write, false),
        group_writers: node_permitted(node, :write, true),
        user_spenders: node_permitted(node, :spend, false),
        group_spenders: node_permitted(node, :spend, true))
  end

  private

  def self.node_permitted(node, permission_type, groups)
    permission_type = permission_type.to_sym
    perms = node.permissions.select { |p| p.permission_type.to_sym==permission_type && p.permitted.include?('@')!=groups }.
      map { |p| p.permitted }
    if permission_type==:read
      if groups
        perms.delete('world')
      elsif node.owner&.email
        perms.delete(node.owner.email.downcase)
      end
    end
    if permission_type==:write && !groups && node.owner&.email
      perms.delete(node.owner.email.downcase)
    end
    perms.join(',')
  end

  def create_objects
    ActiveRecord::Base.transaction do
      node = Node.create!(name: name, cost_code: cost_code, description: description, parent_id: parent_id, owner: @owner)
      node.permissions.create!(convert_permissions)
    end
  rescue
    false
  end

  def update_objects
    ActiveRecord::Base.transaction do
      node = Node.find(id)
      node.update_attributes(name: name, cost_code: cost_code, description: description, parent_id: parent_id)
      node.permissions.destroy_all
      node.set_permissions
      node.permissions.create!(convert_permissions)
    end
  rescue
    false
  end

  def convert_permissions
    permitted = []
    add_to_permission(permitted, user_writers, false, :write)
    add_to_permission(permitted, group_writers, true, :write)
    add_to_permission(permitted, user_spenders, false, :spend)
    add_to_permission(permitted, group_spenders, true, :spend)
    permitted
  end

  def add_to_permission(permitted, people, is_group, permission_type)
    people&.split(',')&.each do |name|
      name = fixname(name, is_group)
      permitted.push({ permitted: name, permission_type: permission_type })
    end
  end

  def fixname(name, is_group)
    name = name.strip.downcase
    name += '@sanger.ac.uk' unless (is_group || name.include?('@'))
    return name
  end

end