FactoryGirl.define do
  factory :permission, class: AkerPermissionGem::Permission do
    accessible_type 'Node'
  end
end
