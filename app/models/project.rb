class Project < ApplicationRecord
  belongs_to :program

  validates :name, presence: true
end
