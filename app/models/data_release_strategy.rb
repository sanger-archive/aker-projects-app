class DataReleaseStrategy < ApplicationRecord
  self.primary_key=:id
  has_many :nodes

  def self.find_or_update_with!(strategy)
    local_strategy = DataReleaseStrategy.find_or_create_by(id: strategy[:id])
    local_strategy.update_attributes!(id: strategy[:id], name: strategy[:name])
    local_strategy
  end

end