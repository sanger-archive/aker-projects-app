class Node < ApplicationRecord
	validates :name, presence: true, uniqueness: true
	validates :parent, presence: true, if: :parent_id

	belongs_to :parent, class_name: 'Node', required: false
	has_many :children, :class_name => 'Node', :foreign_key => 'parent_id'

	def self.root
		self.find_by(parent_id: nil)
	end
end
