FactoryGirl.define do
  factory :node do
    sequence(:name) { |n| "Node #{n}" }
    cost_code nil
    description nil
    parent_id nil
    association :owner, factory: :user

    # Usage: create(:readable_node, permitted: 'cs24')
    #
    # This will create a node as usual, but also create an extra permission object with cs24 as the permitted
    # and r being true
    factory :readable_node do

      transient do
        permitted nil
      end

      after(:create) do |node, evaluator|
        node.permissions << create(:permission, accessible_id: node.id, r: true, permitted: evaluator.permitted)
      end

    end

    # Usage: create(:writable_node, permitted: 'cs24')
    #
    # This will create a node as usual, but also create an extra permission object with cs24 as the permitted
    # and w being true
    factory :writable_node do

      transient do
        permitted nil
      end

      after(:create) do |node, evaluator|
        node.permissions << create(:permission, accessible_id: node.id, w: true, permitted: evaluator.permitted)
      end

    end

    # Usage: create(:executable_node, permitted: 'cs24')
    #
    # This will create a node as usual, but also create an extra permission object with cs24 as the permitted
    # and x being true
    factory :executable_node do

      transient do
        permitted nil
      end

      after(:create) do |node, evaluator|
        node.permissions << create(:permission, accessible_id: node.id, x: true, permitted: evaluator.permitted)
      end

    end
  end
end
