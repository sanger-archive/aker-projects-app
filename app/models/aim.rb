class Aim < ApplicationRecord
  has_many :proposals
  belongs_to :project

  validates :name, presence: true
end
