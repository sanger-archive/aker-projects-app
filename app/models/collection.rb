class Collection < ApplicationRecord
  belongs_to :collector, polymorphic: true

  # Need a set_id to exist and look like a UUID
  validates :set_id,
    length: { :within => 5..500 },
    format: { :with => /[A-Za-z\d][-A-Za-z\d]{3,498}[A-Za-z\d]/ },

    # This gives us the option to either go create a Set in the Set Service
    # or pass in a set_id ourselves
    allow_blank: true

  before_destroy :nullify
  before_create :create_set

  def nullify
    unless set_nullified?
      set.update_attributes(:name => "#{nullified_prefix} #{set.name}")
    end
  end

  def nullified_prefix
    "(DISABLED)"
  end

  def set_nullified?
    set.name.starts_with?(nullified_prefix)
  end

  def set
    SetClient::Set.find(set_id).first
  end

  private

  def create_set
    if self.set_id.nil?
      self.set_id = SetClient::Set.create(name: collector.name).id
    end
  end
end