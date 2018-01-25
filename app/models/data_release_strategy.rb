class DataReleaseStrategy < ApplicationRecord
  self.primary_key=:id
  has_many :nodes

  def update_with_study_info(study)
    update_hash = {}
    if name != study['attributes']['name']
      update_hash[:name] = study['attributes']['name']
    end
    if study_code != study['id']
      update_hash[:study_code] = study['id']
    end
    update_attributes(update_hash)
  end

  def label_to_display
    "#{study_code} #{name}".truncate(30, omission: '...')
  end

end