FactoryGirl.define do
  factory :permission, class: AkerPermissionGem::Permission do
    permitted nil
    r true
    w false
    x false
    accessible_type 'Node'
    accessible_id nil
  end
end
