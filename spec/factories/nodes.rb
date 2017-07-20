FactoryGirl.define do
  factory :node do
    sequence(:name) { |n| "Node #{n}" }
    cost_code nil
    description nil
    parent_id nil
    deactivated_by_id nil
    deactivated_datetime nil
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
        node.permissions << create(:permission, accessible_id: node.id, permission_type: :read, permitted: evaluator.permitted)
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
        node.permissions << create(:permission, accessible_id: node.id, permission_type: :write, permitted: evaluator.permitted)
      end

    end

    # Usage: create(:spendable_node, permitted: 'cs24')
    #
    # This will create a node as usual, but also create an extra permission object with cs24 as the permitted
    # and x being true
    factory :spendable_node do

      transient do
        permitted nil
      end

      after(:create) do |node, evaluator|
        node.permissions << create(:permission, accessible_id: node.id, permission_type: :spend, permitted: evaluator.permitted)
      end

    end
  end
end
