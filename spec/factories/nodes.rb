FactoryGirl.define do
  factory :node do
    sequence(:name) { |n| "Node #{n}" }
    cost_code nil
    description nil
    parent_id nil
    association :owner, factory: :user

    factory :writable_node do

      transient do
        permitted nil
      end

      after(:create) do |node, evaluator|
        node.permissions << create(:permission, accessible_id: node.id, w: true, permitted: evaluator.permitted)
      end

    end
  end
end
