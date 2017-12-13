require 'billing_facade_client'

class Node < ApplicationRecord
  include AkerPermissionGem::Accessible

  validates :name, presence: true
  validates :parent, presence: true, if: :parent_id
  validates_presence_of :description, :allow_blank => true

  validates :cost_code, :presence => true, :allow_blank => true, :on => [:create, :update]
  validates_with BillingFacadeClient::ProjectCostCodeValidator, :on => [:create, :update], if: :is_project?
  validates_with BillingFacadeClient::SubprojectCostCodeValidator, :on => [:create, :update], if: :is_subproject?

  validates :deactivated_datetime, presence: true, unless: :active?
  validates :deactivated_datetime, absence: true, if: :active?
  validates :owner_email, presence: true

  validate :validate_deactivate, unless: :active?
  validate :validate_name_active_uniqueness, if: :active?
  validate :validate_node_is_not_root
  validate :validate_node_cant_move_to_under_root
  validate :validate_node_cant_move_from_under_root
  validate :validate_cant_create_node_under_subproject
  validate :validate_cant_update_project_cost_code_if_subcostcodes_exist

	has_many :nodes, class_name: 'Node', foreign_key: 'parent_id', dependent: :restrict_with_error
	belongs_to :parent, class_name: 'Node', required: false

  before_validation :sanitise_blank_cost_code, :sanitise_name, :sanitise_owner, :sanitise_deactivated_by
  before_save :sanitise_blank_cost_code, :sanitise_name, :sanitise_owner, :sanitise_deactivated_by
  before_create :create_uuid
  before_destroy :validate_root_node_cant_be_destroyed

  after_create :set_permissions

  scope :active, -> { where(deactivated_by: nil) }

  scope :with_cost_code, -> { where(Node.arel_table[:cost_code].matches('S%')) }
  scope :with_project_cost_code, -> { with_cost_code.where.not(Node.arel_table[:cost_code].matches("%#{BillingFacadeClient::CostCodeValidator::SPLIT_CHARACTER}%")) }
  scope :with_subproject_cost_code, -> { with_cost_code.where(Node.arel_table[:cost_code].matches("%#{BillingFacadeClient::CostCodeValidator::SPLIT_CHARACTER}%")) }

  scope :is_project, -> { with_project_cost_code }
  scope :is_subproject, -> { with_subproject_cost_code }

  def is_project?
    # https://stackoverflow.com/questions/524658/what-does-mean-in-ruby
    !!(cost_code && parent && !parent.cost_code)
  end

  def is_subproject?
    !!(cost_code && parent&.cost_code && !parent.cost_code.include?(BillingFacadeClient::CostCodeValidator::SPLIT_CHARACTER))
  end

  def valid_node_for_cost_code?
    (is_project? || is_subproject?)
  end

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

  def validate_cant_create_node_under_subproject
    if self.parent&.is_subproject?
      errors.add(:base, "A node cannot be created under a subproject")
    end
  end

  def validate_cant_update_project_cost_code_if_subcostcodes_exist
    if children_have_subcostcodes? && cost_code_changed
       errors.add(:cost_code, "Cost code cannot be update when there are subprojects")
    end
  end

  def children_have_subcostcodes?
    Node.active.where(parent: self.id).any?{ |child| child.cost_code }
  end

  def cost_code_changed
    if self.id
      old_node = Node.find(self.id)
      old_node.attributes.keys.each do |k|
        if k == "cost_code"
          return false if self[k] == old_node[k]
        end
      end
    end
    true
  end

end