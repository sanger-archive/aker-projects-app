class Project < ApplicationRecord
  has_many :aims
  belongs_to :program

  validates :name, presence: true
end
