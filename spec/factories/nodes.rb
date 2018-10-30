FactoryBot.define do
  factory :node do
    sequence(:name) { |n| "Node #{n}" }
    cost_code nil
    description nil
    parent_id nil
    deactivated_by nil
    deactivated_datetime nil
    owner_email 'owner@sanger.ac.uk'

    # This will create a node as usual, but also create an extra permission object with cs24 as the permitted
    # and r being true
    trait :readable do

      transient do
        permitted nil
      end

      after(:create) do |node, evaluator|
        node.permissions << create(:permission, accessible_id: node.id, permission_type: :read, permitted: evaluator.permitted)
      end
    end

    # This will create a node as usual, but also create an extra permission object with cs24 as the permitted
    # and w being true
    trait :writable do

      transient do
        permitted nil
      end

      after(:create) do |node, evaluator|
        node.permissions << create(:permission, accessible_id: node.id, permission_type: :write, permitted: evaluator.permitted)
      end
    end

    # This will create a node as usual, but also create an extra permission object with cs24 as the permitted
    # and x being true
    trait :spendable do

      transient do
        permitted nil
      end

      after(:create) do |node, evaluator|
        node.permissions << create(:permission, accessible_id: node.id, permission_type: :spend, permitted: evaluator.permitted)
      end
    end

    # Usage: create(:project, parent: parent)
    #
    # A project is a node with a costcode (Sxxxx)
    factory :project do
      cost_code { "S%04d" % rand(9999) }
    end

    # Usage: create(:sub_project, parent: project)
    #
    # A sub-project is a node with a sub-costcode (Sxxxx-xx)
    factory :sub_project do
      cost_code { "#{parent.cost_code}-%02d" % rand(9) }

      factory :spendable_sub_project, traits: [:spendable]
    end

    factory :readable_node, traits: [:readable]
    factory :writable_node, traits: [:writable]
    factory :spendable_node, traits: [:spendable]
  end
end
