class Node < ApplicationRecord
  include Collector
  include AkerPermissionGem::Accessible

  validates :name, presence: true
  validates :parent, presence: true, if: :parent_id
  validates_presence_of :description, :allow_blank => true
  validates :cost_code, :presence => true, :allow_blank => true, format: { with: /\AS[0-9]{4}+\z/ }, :on => [:create, :update]
  validates :deactivated_datetime, presence: true, unless: :active?
  validates :deactivated_datetime, absence: true, if: :active?
  validate :validate_deactivate, unless: :active?
  validate :validate_name_active_uniqueness, if: :active?

	has_many :nodes, class_name: 'Node', foreign_key: 'parent_id', dependent: :restrict_with_error
	belongs_to :parent, class_name: 'Node', required: false
  belongs_to :deactivated_by, class_name: "User"

  before_save :sanitise_blank_cost_code
  after_create :create_uuid

  scope :active, -> { where(deactivated_by_id: nil) }

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

  # Create a collection for this node if it doesn't have one
  def set_collection
    self.collection = build_collection if collection.nil? && !@no_collection
  end

  # A Node is active when its deactivated_by column is null
  def active?
    deactivated_by_id.nil?
  end

  def deactivate(user)
    return true unless active?
    raise ArgumentError, "Node must be deactivated by a User" unless user.id
    update_attributes(deactivated_by: user, deactivated_datetime: DateTime.now)
  end

  def active_children
    nodes.select(&:active?)
  end

  private

  def validate_deactivate
    if nodes.reload.any?(&:active?)
      errors.add(:base, "A node with active children cannot be deactivated.")
    end
  end

  # Name must be unique within the scope of active nodes
  def validate_name_active_uniqueness
    if Node.where(name: name, deactivated_by_id: nil).any? { |n| n.id != id }
      errors.add(:name, "must be unique.")
    end
  end

  def sanitise_blank_cost_code
    if self.cost_code.blank?
      self.cost_code = nil
    end
  end

end
