class TreeLayout < ApplicationRecord
  validates :user_id, presence: true, uniqueness: true

  before_save :sanitise_user
  before_validation :sanitise_user

  def sanitise_user
    if user_id
      sanitised = user_id.strip.downcase
      if sanitised != user_id
        self.user_id = sanitised
      end
    end
  end
  
end
