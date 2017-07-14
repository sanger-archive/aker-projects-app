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
      if value && JOINED_LISTS.include?(attribute)
        value = value.split(',')
      end
      send("#{attribute}=", value)
    end
    @owner = attributes[:owner]
  end

  def parent_id
    @parent_id ||= parent.id
  end

  def save
    #TODO valid? currently does nothing
    valid? && (id ? update_objects : create_objects)
  end

  private

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
    people&.each do |name|
      name = fixname(name, is_group)
      permitted.push({ permitted: name, permission_type: permission_type })
    end
  end

  def fixname(name, is_group)
    unless (is_group || name.include?('@'))
      name += '@sanger.ac.uk'
    end
    name.downcase
  end

end