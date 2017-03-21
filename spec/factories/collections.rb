FactoryGirl.define do
  factory :collection do
    set_id SecureRandom.uuid
    association :collector, factory: :node
  end
end