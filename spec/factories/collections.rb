FactoryGirl.define do
  factory :collection do
    set_id nil
    association :collector, factory: :node
  end
end