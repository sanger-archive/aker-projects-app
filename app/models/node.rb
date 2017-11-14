class Node < ApplicationRecord
  include AkerPermissionGem::Accessible

  validates :name, presence: true
  validates :parent, presence: true, if: :parent_id
  validates_presence_of :description, :allow_blank => true
  validates :cost_code, :presence => true, :allow_blank => true, format: { with: /\AS[0-9]{4}+\z/, message: 'must be of the format "S" followed by four digits' }, :on => [:create, :update]
  validates :deactivated_datetime, presence: true, unless: :active?
  validates :deactivated_datetime, absence: true, if: :active?
  validates :owner_email, presence: true

  validate :validate_deactivate, unless: :active?
  validate :validate_name_active_uniqueness, if: :active?
  validate :validate_node_is_not_root
  validate :validate_node_cant_move_to_under_root
  validate :validate_node_cant_move_from_under_root

	has_many :nodes, class_name: 'Node', foreign_key: 'parent_id', dependent: :restrict_with_error
	belongs_to :parent, class_name: 'Node', required: false

  before_validation :sanitise_blank_cost_code, :sanitise_name, :sanitise_owner, :sanitise_deactivated_by
  before_save :sanitise_blank_cost_code, :sanitise_name, :sanitise_owner, :sanitise_deactivated_by
  before_create :create_uuid
  before_destroy :validate_root_node_cant_be_destroyed

  after_create :set_permissions

  scope :active, -> { where(deactivated_by: nil) }

  def set_permissions
    if owner_email
      set_default_permission(owner_email)
      self.permissions.create(permitted: owner_email, permission_type: :spend)
    end
  end

  def create_uuid
    self.node_uuid ||= SecureRandom.uuid
  end

  def self.root
		find_by(parent_id: nil)
	end

  def root?
    parent_id.nil?
  end

  def level
    parents.size + 1
  end

  # Returns true if the node is a direct descendant of the root node so the modal
  # can be clear that these nodes cannot be edited (even though they have world edit
  # permission)
  def world_node?
    !root? && parent.root?
  end

  # Gets the parents of a node,
  # starting from root, ending at the node's direct parent
	def parents
    parents = []
    p = parent
    while p do
      parents.push(p)
      p = p.parent
    end
    parents.reverse
  end

  # A Node is active when its deactivated_by column is null
  def active?
    deactivated_by.nil?
  end

  def deactivate(user_email)
    return true unless active?
    raise ArgumentError, "Node must be deactivated by a User" unless user_email
    update_attributes(deactivated_by: user_email, deactivated_datetime: DateTime.now)
  end

  def active_children
    nodes.select(&:active?)
  end

  def sanitise_name
    if name
      sanitised = name.strip.gsub(/\s+/, ' ')
      if sanitised != name
        self.name = sanitised
      end
    end
  end

  def sanitise_owner
    if owner_email
      sanitised = owner_email.strip.downcase
      if sanitised != owner_email
        self.owner_email = sanitised
      end
    end
  end

  def sanitise_deactivated_by
    if deactivated_by
      sanitised = deactivated_by.strip.downcase
      if sanitised != deactivated_by
        self.deactivated_by = sanitised
      end
    end
  end

  private

  def validate_deactivate
    if nodes.reload.any?(&:active?)
      errors.add(:base, "A node with active children cannot be deactivated")
    end
  end

  # Name must be unique within the scope of active nodes
  def validate_name_active_uniqueness
    if Node.where(name: name, deactivated_by: nil).any? { |n| n.id != id }
      errors.add(:name, "must be unique")
    end
  end

  def validate_node_is_not_root
    unless self.parent_id
      errors.add(:base, "The root node cannot be created/updated")
    end
  end

  def validate_node_cant_move_to_under_root
    former_parent = parent_id_was ? Node.find(parent_id_was) : nil
    if !former_parent&.root? && parent&.root?
      errors.add(:base, "A node cannot be moved to under the root node")
    end
  end

  def validate_node_cant_move_from_under_root
    former_parent = parent_id_was ? Node.find(parent_id_was) : nil
    if former_parent&.root? && !parent&.root?
      errors.add(:base, "A node cannot be moved from under the root node")
    end
  end

  def validate_root_node_cant_be_destroyed
    if self.root?
      errors.add(:base, "The root node cannot be deleted")
    end
  end

  def sanitise_blank_cost_code
    if self.cost_code.blank?
      self.cost_code = nil
    end
  end

end
