class NodeForm

  # ActiveModel plumbing to make `form_for` work
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  def persisted?
    false
  end

  ATTRIBUTES = [:parent_id, :name, :description, :cost_code, :user_writers, :group_writers, :user_spenders, :group_spenders]

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
    valid? && create_objects
  end

  private

  def create_objects
    ActiveRecord::Base.transaction do
      n = Node.create!(name: name, cost_code: cost_code, description: description, parent_id: parent_id, owner: @owner)
      permitted = {}
      add_to_permission(permitted, user_writers, false, :w)
      add_to_permission(permitted, group_writers, true, :w)
      add_to_permission(permitted, user_spenders, false, :x)
      add_to_permission(permitted, group_spenders, true, :x)
      n.permissions.create!(permitted.values)
    end
  rescue
    false
  end

  def add_to_permission(permitted, people, is_group, permission_type)
    people&.each do |name|
      name = fixname(name, is_group)
      perm = permitted[name]
      if perm
        perm[permission_type] = true
      else
        perm = { permitted: name, r: true, permission_type => true }
        permitted[name] = perm
      end
    end
  end

  def fixname(name, is_group)
    unless (is_group || name.include?('@'))
      name += '@sanger.ac.uk'
    end
    name.downcase
  end

end