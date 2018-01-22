class DataReleaseStrategy < ApplicationRecord
  self.primary_key=:id
  has_many :nodes

end