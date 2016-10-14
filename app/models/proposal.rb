class Proposal < ApplicationRecord
  belongs_to :aim

  validates :name, presence: true
end
