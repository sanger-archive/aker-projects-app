FactoryGirl.define do
  factory :proposal do
    sequence(:name) { |n| "Proposal #{n}" }
    aim
  end
end
