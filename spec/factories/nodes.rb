FactoryGirl.define do
  factory :node do
    sequence(:name) { |n| "Node #{n}" }
    cost_code nil
    description nil
    parent_id nil
  end
end
