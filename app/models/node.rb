class Node < ApplicationRecord
    include Collector

	validates :name, presence: true, uniqueness: true
	validates :parent, presence: true, if: :parent_id
	
	has_many :nodes, class_name: 'Node', foreign_key: 'parent_id', dependent: :restrict_with_error
	belongs_to :parent, class_name: 'Node', required: false

	def self.root
		find_by(parent_id: nil)
	end

  def root?
    parent_id.nil?
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
end
