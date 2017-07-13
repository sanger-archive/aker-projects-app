class NodeForm

  # ActiveModel plumbing to make `form_for` work
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  def persisted?
    false
  end

  ATTRIBUTES = [:parent, :parent_id, :name, :description, :cost_code, :user_writers, :group_writers, :user_spenders, :group_spenders]

  attr_accessor *ATTRIBUTES

  def initialize(attributes = {})
    ATTRIBUTES.each do |attribute|
      send("#{attribute}=", attributes[attribute])
    end
  end

  def parent_id
    @parent_id ||= parent.id
  end

  def save
    return false unless valid?
    debugger
    if create_objects
      true
    else
      false
    end
  end

  private

  def create_objects
    ActiveRecord::Base.transaction do

    end
  rescue
    false
  end

end