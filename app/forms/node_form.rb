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
      n = Node.create!(name: name, cost_code: cost_code, description: description, parent_id: parent_id, owner: @owner)
      n.permissions.create!(convert_permissions.values)
    end
  rescue
    false
  end

  def update_objects
    ActiveRecord::Base.transaction do
      node = Node.find(id)
      node.update_attributes(name: name, cost_code: cost_code, description: description, parent_id: parent_id)
      permitted = convert_permissions
      world = permitted['world'] || { w: false, x: false }
      owner_permissions = permitted[owner.email] || { x: false }
      permitted['world'] = { permitted: 'world', r: true, w: world[:w], x: world[:x] }
      permitted[owner.email] = { permitted: owner.email, r: true, w: true, x: owner_permissions[:x] }
      node.permissions.each do |perm|
        new_perm = permitted[perm.permitted]
        if !new_perm
          perm.destroy()
        else
          if [:r, :w, :x].any? { |ptype| new_perm[ptype]!=perm.send(ptype.to_s) }
            perm.update_attributes!(new_perm)
            permitted.delete!(perm.permitted)
          end
        end
      end
      node.permissions.create!(permitted.values)
    end
  rescue
    false
  end

  def convert_permissions
    permitted = { }
    add_to_permission(permitted, user_writers, false, :w)
    add_to_permission(permitted, group_writers, true, :w)
    add_to_permission(permitted, user_spenders, false, :x)
    add_to_permission(permitted, group_spenders, true, :x)
    permitted
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