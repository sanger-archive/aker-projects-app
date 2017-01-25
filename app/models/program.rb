class Program < ApplicationRecord
  include Collector

  has_many :projects

  validates :name, presence: true
end
