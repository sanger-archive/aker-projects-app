class Collection < ApplicationRecord
  belongs_to :collector, polymorphic: true

  # Need a set_id to exist and look like a UUID
  validates :set_id,
    length: { :within => 5..500 },
    format: { :with => /[A-Za-z\d][-A-Za-z\d]{3,498}[A-Za-z\d]/ },

    # This gives us the option to either go create a Set in the Set Service
    # or pass in a set_id ourselves
    allow_blank: true

  # TODO Need to actually go create a new Set
  # in the Set Service when a Collection is made

  # Generate a set_id if the collection doesn't already have one (for some reason)
  before_create do
    self.set_id = SecureRandom.uuid unless self.set_id?
  end
end
